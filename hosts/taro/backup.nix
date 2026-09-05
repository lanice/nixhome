# Nightly taro recovery set. A completed Forgejo dump anchors the backup, but
# the set also contains host, Roundcube and remote coding state.
{
  config,
  lib,
  pkgs,
  ...
}: let
  # Keep the established repository identity: landing and offsite history,
  # credentials, and recovery material all use "forgejo".
  boba = (import ../fleet.nix).hosts.boba;
  roundcubeDump = "/var/lib/roundcube/roundcube.sql";
  t3codeHome = config.users.users.t3code.home;
  # Disposable databases; exclude SQLite sidecars too.
  sqliteSources = [
    "${t3codeHome}/.t3/userdata/state.sqlite"
    "${t3codeHome}/.codex/*.sqlite"
  ];
in {
  services.restic.backups.forgejo = {
    repository = "rest:http://${boba.tailscaleIP}:8000/forgejo";
    environmentFile = config.age.secrets.resticForgejoTransport.path;
    paths = [
      config.services.forgejo.dump.backupDir
      "/var/lib/tailscale"
      "/var/lib/forgejo/.ssh/authorized_keys"
      "/var/lib/roundcube/des_key"
      roundcubeDump
      "/var/lib/acme"
      t3codeHome
    ];
    exclude =
      lib.concatMap (path: [path "${path}-wal" "${path}-shm" "${path}-journal"]) sqliteSources
      ++ [
        "${t3codeHome}/workspaces"
        "${t3codeHome}/.t3/worktrees"
        "${t3codeHome}/.cache"
        "${t3codeHome}/.npm"
        "${t3codeHome}/.local/share/pnpm/store"
        "${t3codeHome}/.bun/install/cache"
        "${t3codeHome}/.cargo/registry"
        "${t3codeHome}/.cargo/git"
        "${t3codeHome}/.t3/caches"
        "${t3codeHome}/.codex/tmp"
        "${t3codeHome}/.codex/models_cache.json"
      ];
    passwordFile = config.age.secrets.resticForgejoPassword.path;
    initialize = true;
    extraBackupArgs = ["--retry-lock=1h"];
    timerConfig = null;
    user = "root";

    # Roundcube uses PostgreSQL peer authentication, so pg_dump must run as its
    # database owner. Any dump failure aborts restic, not just publication.
    backupPrepareCommand = ''
      set -eu
      umask 077
      temporary=${roundcubeDump}.tmp
      ${pkgs.coreutils}/bin/rm -f "$temporary"
      trap '${pkgs.coreutils}/bin/rm -f "$temporary"' EXIT
      ${pkgs.util-linux}/bin/runuser -u ${config.services.roundcube.database.username} -- \
        ${config.services.postgresql.package}/bin/pg_dump \
        --dbname=${config.services.roundcube.database.dbname} \
        --file="$temporary"
      ${pkgs.coreutils}/bin/mv -f "$temporary" ${roundcubeDump}
    '';
  };

  # OnSuccess is the trigger. After= alone would only order a restic job that
  # something else had already requested.
  systemd.services.forgejo-dump.unitConfig.OnSuccess = "restic-backups-forgejo.service";
  systemd.services.restic-backups-forgejo.unitConfig.OnFailure = "notify-failure@%n.service";
}
