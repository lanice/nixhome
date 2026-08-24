{
  config,
  lib,
  pkgs,
  ...
}: let
  dumpDir = "/var/lib/postgresql/backup";
  dumpFile = "${dumpDir}/pg_dumpall.sql";

  # Each inner list is one atomic ZFS snapshot operation, so it must contain
  # datasets from exactly one pool. Every source lifecycle operation below is
  # derived from these records.
  snapshotGroups = [
    [
      {
        dataset = "system/home";
        mountPoint = "/run/backup/home";
        bindSource = "/run/backup/home";
        bindTarget = "/home";
      }
      {
        dataset = "system/var";
        mountPoint = "/run/backup/var";
        bindSource = "/run/backup/var/lib";
        bindTarget = "/var/lib";
      }
    ]
    [
      {
        dataset = "data/storage";
        mountPoint = "/run/backup/storage";
        bindSource = "/run/backup/storage";
        bindTarget = "/data/storage";
      }
      {
        dataset = "data/media";
        mountPoint = "/run/backup/media";
        bindSource = "/run/backup/media";
        bindTarget = "/data/media";
      }
    ]
  ];
  snapshotSources = lib.concatLists snapshotGroups;
  cleanupSources = lib.reverseList snapshotSources;
  snapshotName = source: "${source.dataset}@backup";

  unmountSnapshots = pkgs.writeShellScript "boba-backup-unmount" ''
    set -u

    status=0

    for mountpoint in ${lib.escapeShellArgs (map (source: source.mountPoint) cleanupSources)}; do
      if ${pkgs.util-linux}/bin/mountpoint --quiet "$mountpoint"; then
        ${pkgs.util-linux}/bin/umount --recursive "$mountpoint" || status=1
      fi
    done

    exit "$status"
  '';

  cleanup = pkgs.writeShellScript "boba-backup-cleanup" ''
    set -u

    status=0
    ${unmountSnapshots} || status=1

    for snapshot in ${lib.escapeShellArgs (map snapshotName cleanupSources)}; do
      if ${pkgs.zfs}/bin/zfs list -H -o name -t snapshot "$snapshot" >/dev/null 2>&1; then
        ${pkgs.zfs}/bin/zfs destroy "$snapshot" || status=1
      fi
    done

    exit "$status"
  '';

  prepare = pkgs.writeShellScript "boba-backup-prepare" ''
    set -eu

    ${pkgs.coreutils}/bin/install -d -m 0700 ${lib.escapeShellArgs (map (source: source.mountPoint) snapshotSources)}

    # This is the only logical database dump. Container databases below are
    # deliberately covered only by the crash-consistent ZFS snapshots.
    ${pkgs.coreutils}/bin/install -d -o postgres -g postgres -m 0700 ${dumpDir}
    ${pkgs.coreutils}/bin/rm -f ${dumpFile}.tmp
    trap '${pkgs.coreutils}/bin/rm -f ${dumpFile}.tmp' EXIT
    ${pkgs.util-linux}/bin/runuser --user postgres -- \
      ${config.services.postgresql.package}/bin/pg_dumpall --file=${dumpFile}.tmp
    ${pkgs.coreutils}/bin/mv -f ${dumpFile}.tmp ${dumpFile}
    trap - EXIT

    # TXGs are pool-local. Take one atomic snapshot set per pool; OpenZFS
    # rejects a single multi-pool invocation with EXDEV.
    ${lib.concatMapStringsSep "\n" (
        group: "${pkgs.zfs}/bin/zfs snapshot ${lib.escapeShellArgs (map snapshotName group)}"
      )
      snapshotGroups}

    # Explicit mounts are stable bind sources. Do not use lazy .zfs/snapshot
    # automounts: they are created in the init namespace and can expire.
    ${lib.concatMapStringsSep "\n" (
        source: "${pkgs.util-linux}/bin/mount -t zfs -o ro ${lib.escapeShellArg (snapshotName source)} ${lib.escapeShellArg source.mountPoint}"
      )
      snapshotSources}
  '';

  hostUnmount = pkgs.writeShellScript "boba-backup-host-unmount" ''
    exec ${pkgs.util-linux}/bin/nsenter \
      --mount=/proc/1/ns/mnt \
      --root=/proc/1/root \
      --wd=/proc/1/root \
      ${unmountSnapshots}
  '';

  hostPrepare = pkgs.writeShellScript "boba-backup-host-prepare" ''
    set -eu

    # The preceding ExecStartPre released any cloned stale mounts. Cleanup can
    # now destroy stale snapshots before the current snapshot sets are created.
    ${pkgs.util-linux}/bin/nsenter \
      --mount=/proc/1/ns/mnt \
      --root=/proc/1/root \
      --wd=/proc/1/root \
      ${cleanup}
    exec ${pkgs.util-linux}/bin/nsenter \
      --mount=/proc/1/ns/mnt \
      --root=/proc/1/root \
      --wd=/proc/1/root \
      ${prepare}
  '';
  hostCleanup = pkgs.writeShellScript "boba-backup-host-cleanup" ''
    exec ${pkgs.util-linux}/bin/nsenter \
      --mount=/proc/1/ns/mnt \
      --root=/proc/1/root \
      --wd=/proc/1/root \
      ${cleanup}
  '';
in {
  services.restic.backups.boba = {
    repository = "rest:http://127.0.0.1:8000/boba";
    environmentFile = config.age.secrets.resticBobaTransport.path;
    passwordFile = config.age.secrets.resticBobaPassword.path;
    initialize = true;

    paths = [
      "/home"
      "/var/lib"
      "/data/storage"
      "/data/media/books"
      "/data/media/music"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
    exclude = [
      "/var/lib/containers"
      "/var/lib/jellyfin/data/trickplay"
      "/var/lib/navidrome/cache"
      "/var/lib/minecraft"
    ];
    extraBackupArgs = ["--retry-lock=1h"];
    timerConfig = {
      OnCalendar = "03:00";
      Persistent = true;
    };
  };

  systemd.services.restic-backups-boba = {
    after = [
      "postgresql.service"
      "restic-rest-server.service"
      "zfs-mount.service"
    ];
    requires = [
      "postgresql.service"
      "restic-rest-server.service"
      "zfs-mount.service"
    ];
    path = [pkgs.zfs];
    unitConfig.OnFailure = "notify-failure@%n.service";
    serviceConfig = {
      # `+` restores the privileges needed by nsenter, but does not disable the
      # unit's filesystem namespace. The first hook unmounts stale host mounts
      # and exits, releasing its cloned namespace; the second enters PID 1's
      # clean mount view to destroy stale snapshots and prepare the backup.
      ExecStartPre = lib.mkBefore [
        "+${hostUnmount}"
        "+${hostPrepare}"
      ];
      ExecStopPost = lib.mkBefore ["+${hostCleanup}"];
      # `-` permits missing sources while the privileged hooks start. Prepare
      # mounts every source before the module-generated preStart and ExecStart.
      BindReadOnlyPaths =
        map (source: "-${source.bindSource}:${source.bindTarget}") snapshotSources;
    };
  };
}
