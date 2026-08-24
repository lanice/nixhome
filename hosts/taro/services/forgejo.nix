{
  inputs,
  config,
  pkgs,
  ...
}: let
  pub = config.homelab.published.git;

  # Each host evaluates only its own config; cross-host facts come from the fleet registry.
  boba = (import ../../fleet.nix).hosts.boba;
  roundcubeDump = "/var/lib/roundcube/roundcube.sql";
in {
  services.forgejo = {
    enable = true;

    # Whole forge state (SQLite DB, repos, LFS, config) lives under
    # /var/lib/forgejo, so a dump — and the nightly ship below — is a
    # complete backup.
    lfs.enable = true;

    settings = {
      server = {
        DOMAIN = pub.fqdn;
        ROOT_URL = "${pub.url}/";
        # nginx proxies from the tailnet address; nothing else should reach
        # the plain-HTTP listener.
        HTTP_ADDR = "127.0.0.1";
      };

      session.COOKIE_SECURE = true;

      # Single-user instance. The admin account was created imperatively once;
      # the module keeps the CLI off PATH, so admin commands run as:
      #   sudo -u forgejo env FORGEJO_WORK_DIR=/var/lib/forgejo \
      #     FORGEJO_CUSTOM=/var/lib/forgejo/custom \
      #     $(grep -oP 'ExecStart=\K\S+' /etc/systemd/system/forgejo.service) \
      #     admin user create --admin --username lanice --random-password --email ...
      service.DISABLE_REGISTRATION = true;

      actions.ENABLED = true;
    };

    # Uncompressed tar lets restic deduplicate the roughly 3 GiB nightly dump.
    # The restic job below is the durable history; local dumps only bridge two
    # nights and continue shipping to the legacy rsync landing until ticket 10.
    dump = {
      enable = true;
      type = "tar";
      age = "2d";
    };
  };

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
    ];
    passwordFile = config.age.secrets.resticForgejoPassword.path;
    initialize = true;
    extraBackupArgs = ["--retry-lock=1h"];
    timerConfig = null;
    user = "root";

    # Roundcube uses PostgreSQL peer authentication, so pg_dump must run as its
    # database owner. A failed dump leaves the previous complete file in place
    # and fails this pre-hook; restic never sees a partial or stale replacement.
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
  systemd.services.forgejo-dump.unitConfig = {
    OnSuccess = "restic-backups-forgejo.service";
    OnFailure = "notify-failure@%n.service";
  };
  systemd.services.restic-backups-forgejo.unitConfig.OnFailure = "notify-failure@%n.service";

  homelab.published.git = {
    proxyTo = config.services.forgejo.settings.server.HTTP_PORT;
  };

  age.secrets.forgejo-dump-key = {
    file = "${inputs.self}/secrets/forgejo-dump-key.age";
    owner = config.services.forgejo.user;
    mode = "400";
  };

  programs.ssh.knownHosts.${boba.tailscaleIP}.publicKey = boba.hostKey;

  # taro is a single unbacked-up SSD; boba's raidz1 pool holds the durable
  # copy (landing side in hosts/boba/services/forgejo-runner.nix). Runs 44
  # minutes after the 04:31 dump.
  systemd.services.forgejo-dump-ship = {
    description = "Ship Forgejo dumps to boba";
    serviceConfig = {
      Type = "oneshot";
      User = config.services.forgejo.user;
      Group = config.services.forgejo.group;
      ExecStart = ''${pkgs.rsync}/bin/rsync -a --delete -e "${pkgs.openssh}/bin/ssh -i ${config.age.secrets.forgejo-dump-key.path}" ${config.services.forgejo.dump.backupDir}/ forgejo-dumps@${boba.tailscaleIP}:/data/storage/forgejo-dumps/'';
    };
  };

  systemd.timers.forgejo-dump-ship = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "*-*-* 05:15:00";
      Persistent = true;
    };
  };
}
