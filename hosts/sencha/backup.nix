{
  config,
  pkgs,
  ...
}: let
  boba = (import ../fleet.nix).hosts.boba;
  pingHealthcheck = pkgs.writeShellScript "sencha-backup-healthcheck" ''
    uuid=$(${pkgs.coreutils}/bin/cat ${config.age.secrets.resticSenchaHealthcheckUuid.path})
    exec ${pkgs.curl}/bin/curl -fsS -m 10 --retry 5 "https://hc-ping.com/$uuid"
  '';
in {
  services.restic.backups.sencha = {
    repository = "rest:http://${boba.tailscaleIP}:8000/sencha";
    environmentFile = config.age.secrets.resticSenchaTransport.path;
    passwordFile = config.age.secrets.resticSenchaPassword.path;
    # The module's initializer mistakes an active prune lock for a missing
    # repository. Probe read-only without a lock, bound backend retries when
    # boba is unreachable, and initialize only for restic's missing-repo code.
    # 180s: the Persistent catch-up fires ~8s after boot, before the tailnet
    # is usable; a boot on 2026-08-25 needed 96s for the path to boba.
    initialize = false;
    backupPrepareCommand = ''
      #!${pkgs.runtimeShell}
      set +e
      ${pkgs.coreutils}/bin/timeout --signal=TERM --kill-after=5s 180s \
        ${pkgs.restic}/bin/restic --no-lock cat config >/dev/null
      status=$?
      set -e

      case "$status" in
        0)
          ;;
        10)
          ${pkgs.restic}/bin/restic init
          ;;
        *)
          exit "$status"
          ;;
      esac
    '';
    inhibitsSleep = true;

    paths = [
      "/home/lanice"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ];
    exclude = [
      "/home/lanice/Sync/photo-share"
      "/home/lanice/Sync/books"
      "/home/lanice/Sync/sd*"
      "/home/lanice/Sync/stable-diffusion"
      "/home/lanice/Games"
      "/home/lanice/.cache"
      "/home/lanice/.local/share/Steam"
      "/home/lanice/.steam"
      "/home/lanice/.local/share/lutris"
      "/home/lanice/.local/share/PrismLauncher"
      "/home/lanice/.local/share/Trash"
      "/home/lanice/.config/Claude"
      "/home/lanice/.thunderbird/lanice/ImapMail"
      "/home/lanice/.thunderbird/lanice/global-messages-db.sqlite"
      "/home/lanice/.npm"
      "/home/lanice/.cargo/registry"
      "/home/lanice/.rustup"
      "/home/lanice/.local/share/pnpm/store"
      "/home/lanice/go/pkg"
      "/home/lanice/.local/share/umu"
      "/home/lanice/.local/share/whisper-models"
      "/home/lanice/.bun/install/cache"
      "node_modules"
      ".venv"
      "venv"
      ".next"
      "dist"
      "build"
      "target"
      ".direnv"
      "__pycache__"
      ".turbo"
      ".mypy_cache"
      ".pytest_cache"
      ".ruff_cache"
    ];
    extraBackupArgs = [
      "--exclude-caches"
      "--exclude-if-present=.nobackup"
      "--retry-lock=30m"
    ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
    };
  };

  systemd.services.restic-backups-sencha = {
    unitConfig.ConditionACPower = true;
    serviceConfig.ExecStartPost = pingHealthcheck;
  };
}
