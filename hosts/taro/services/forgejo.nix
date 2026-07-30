{
  inputs,
  config,
  pkgs,
  ...
}: let
  pub = config.homelab.published.git;

  # boba's tailnet address (homelab.tailscaleIP in hosts/boba/services/default.nix).
  # Referenced by literal because each host evaluates its own homelab registry.
  bobaTailscaleIP = "100.124.185.117";
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

    # GitHub push mirrors only carry git data — issues, PRs, releases and
    # config need these dumps. Pruned after 4 weeks by the module's tmpfiles
    # rule; the ship unit mirrors that retention to boba with --delete.
    dump = {
      enable = true;
      type = "tar.zst";
    };
  };

  homelab.published.git = {
    proxyTo = config.services.forgejo.settings.server.HTTP_PORT;
  };

  age.secrets.forgejo-dump-key = {
    file = "${inputs.self}/secrets/forgejo-dump-key.age";
    owner = config.services.forgejo.user;
    mode = "400";
  };

  programs.ssh.knownHosts.${bobaTailscaleIP}.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGMTGnHrTZedzzB7ssfr0yjPTrIpL4g19Yzi/46dVBdt";

  # taro is a single unbacked-up SSD; boba's raidz1 pool holds the durable
  # copy (landing side in hosts/boba/services/forgejo-runner.nix). Runs 44
  # minutes after the 04:31 dump.
  systemd.services.forgejo-dump-ship = {
    description = "Ship Forgejo dumps to boba";
    serviceConfig = {
      Type = "oneshot";
      User = config.services.forgejo.user;
      Group = config.services.forgejo.group;
      ExecStart = ''${pkgs.rsync}/bin/rsync -a --delete -e "${pkgs.openssh}/bin/ssh -i ${config.age.secrets.forgejo-dump-key.path}" ${config.services.forgejo.dump.backupDir}/ forgejo-dumps@${bobaTailscaleIP}:/data/storage/forgejo-dumps/'';
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
