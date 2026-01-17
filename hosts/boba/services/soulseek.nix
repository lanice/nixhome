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

  age.secrets.slskd = {
    file = "${inputs.self}/secrets/slskd.age";
    owner = user;
    mode = "400";
  };

  services.slskd = {
    enable = true;
    domain = null;
    user = user;
    group = mediaGroup;
    environmentFile = config.age.secrets.slskd.path;
    settings = {
      web.port = 5030;
      directories = {
        downloads = "${downloadDir}/complete";
        incomplete = "${downloadDir}/incomplete";
      };
      shares.directories = [];
    };
  };
}
