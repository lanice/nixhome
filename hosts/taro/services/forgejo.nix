{
  inputs,
  config,
  pkgs,
  ...
}: let
  pub = config.homelab.published.git;

  # Each host evaluates only its own config; cross-host facts come from the fleet registry.
  boba = (import ../../fleet.nix).hosts.boba;
in {
  services.forgejo = {
    enable = true;

    # Whole forge state (SQLite DB, repos, LFS, config) lives under
    # /var/lib/forgejo, so the dump and legacy nightly ship below contain a
    # complete Forgejo backup.
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
    # The host backup in ../backup.nix keeps durable history; local dumps bridge
    # two nights and continue shipping to the legacy rsync landing until ticket 10.
    dump = {
      enable = true;
      type = "tar";
      age = "2d";
    };
  };

  systemd.services.forgejo-dump.unitConfig.OnFailure = "notify-failure@%n.service";

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
