{
  inputs,
  config,
  ...
}: let
  user = "slskd";
  mediaGroup = "multimedia";
  downloadDir = "/downloads/soulseek";
in {
  systemd.tmpfiles.rules = [
    "d ${downloadDir} 0770 ${user} ${mediaGroup} - -"
    "d ${downloadDir}/incomplete 0770 ${user} ${mediaGroup} - -"
    "d ${downloadDir}/complete 0770 ${user} ${mediaGroup} - -"
  ];

  systemd.services.slskd.serviceConfig.UMask = "0002";

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
      # 664 so lidarr/explo can write completed downloads via the multimedia
      # group. slskd 0.25 moved these keys out of a top-level `permissions`
      # block (slskd/slskd#1756) — 0.26 refuses to start on the old path.
      transfers.download.destination.permissions.mode = "664";
      shares.directories = [];
    };
  };

  homelab.published.slskd.proxyTo = config.services.slskd.settings.web.port;
}
