{
  config,
  lib,
  pkgs,
  ...
}: let
  dumpDir = "/var/lib/postgresql/backup";
  dumpFile = "${dumpDir}/pg_dumpall.sql";

  unmountSnapshots = pkgs.writeShellScript "boba-backup-unmount" ''
    set -u

    status=0

    for mountpoint in \
      /run/backup/media \
      /run/backup/storage \
      /run/backup/var \
      /run/backup/home
    do
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

    for snapshot in \
      data/media@backup \
      data/storage@backup \
      system/var@backup \
      system/home@backup
    do
      if ${pkgs.zfs}/bin/zfs list -H -o name -t snapshot "$snapshot" >/dev/null 2>&1; then
        ${pkgs.zfs}/bin/zfs destroy "$snapshot" || status=1
      fi
    done

    exit "$status"
  '';

  prepare = pkgs.writeShellScript "boba-backup-prepare" ''
    set -eu

    ${pkgs.coreutils}/bin/install -d -m 0700 \
      /run/backup/home \
      /run/backup/var \
      /run/backup/storage \
      /run/backup/media

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
    ${pkgs.zfs}/bin/zfs snapshot \
      system/home@backup \
      system/var@backup
    ${pkgs.zfs}/bin/zfs snapshot \
      data/storage@backup \
      data/media@backup

    # Explicit mounts are stable bind sources. Do not use lazy .zfs/snapshot
    # automounts: they are created in the init namespace and can expire.
    ${pkgs.util-linux}/bin/mount -t zfs -o ro system/home@backup /run/backup/home
    ${pkgs.util-linux}/bin/mount -t zfs -o ro system/var@backup /run/backup/var
    ${pkgs.util-linux}/bin/mount -t zfs -o ro data/storage@backup /run/backup/storage
    ${pkgs.util-linux}/bin/mount -t zfs -o ro data/media@backup /run/backup/media
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
      BindReadOnlyPaths = [
        "-/run/backup/home:/home"
        "-/run/backup/var/lib:/var/lib"
        "-/run/backup/storage:/data/storage"
        "-/run/backup/media:/data/media"
      ];
    };
  };
}
