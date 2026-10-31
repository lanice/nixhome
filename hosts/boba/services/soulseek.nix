{
  inputs,
  config,
  ...
}: let
  user = "slskd";
  mediaGroup = config.homelab.media.group;
  downloadDir = config.homelab.media.shares.soulseek.path;
in {
  homelab.media.shares = {
    "soulseek" = {
      under = "downloads";
      owner = user;
    };
    "soulseek/incomplete" = {
      under = "downloads";
      owner = user;
    };
    "soulseek/complete" = {
      under = "downloads";
      owner = user;
    };
  };

  systemd.services.slskd.serviceConfig.UMask = "0002";
  # .NET >= 10.0.13 puts named mutexes in $HOME; slskd's is read-only
  # /var/empty, so 0.26.1 exits 0 at startup. Fixed in slskd 0.26.2 (slskd/slskd#1893).
  systemd.services.slskd.environment.HOME = "/var/lib/slskd";

  age.secrets.slskd = {
    file = "${inputs.self}/secrets/slskd.age";
    owner = user;
    mode = "400";
  };

  services.slskd = {
    enable = true;
    domain = null;
    inherit user;
    group = mediaGroup;
    environmentFile = config.age.secrets.slskd.path;
    settings = {
      web.port = 5030;
      directories = {
        downloads = "${downloadDir}/complete";
        incomplete = "${downloadDir}/incomplete";
      };
      # 664 so lidarr can write completed downloads via the multimedia
      # group. slskd 0.25 moved these keys out of a top-level `permissions`
      # block (slskd/slskd#1756) — 0.26 refuses to start on the old path.
      transfers.download.destination.permissions.mode = "664";
      shares.directories = [];
    };
  };

  homelab.published.slskd.proxyTo = config.services.slskd.settings.web.port;
}
