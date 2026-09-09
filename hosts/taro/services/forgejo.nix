{config, ...}: let
  pub = config.homelab.published.git;
in {
  services.forgejo = {
    enable = true;

    # The dump captures SQLite, repositories, LFS and config under /var/lib/forgejo.
    lfs.enable = true;

    settings = {
      server = {
        DOMAIN = pub.fqdn;
        ROOT_URL = "${pub.url}/";
        # nginx proxies from the tailnet address; nothing else should reach
        # the plain-HTTP listener.
        HTTP_ADDR = "127.0.0.1";
        HTTP_PORT = 13000;
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
    # ../backup.nix sends each completed dump to boba; boba copies it to B2.
    # Local dumps only bridge two nights.
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
}
