let
  mediaDir = "/data/media";
  mediaGroup = "multimedia";
  downloadDir = "/data/downloads";
in {
  users.users.lanice.extraGroups = [mediaGroup];

  users.groups.${mediaGroup} = {};

  systemd.tmpfiles.rules = [
    "d ${mediaDir} 0770 root ${mediaGroup} - -"
    "d ${mediaDir}/movies 0770 - ${mediaGroup} - -"
    "d ${mediaDir}/shows 0770 - ${mediaGroup} - -"
    "d ${downloadDir} 0770 sabnzbd ${mediaGroup} - -"
    "d ${downloadDir}/incomplete 0770 sabnzbd ${mediaGroup} - -"
    "d ${downloadDir}/complete 0770 sabnzbd ${mediaGroup} - -"
  ];

  services.jellyfin = {
    enable = true;
    group = mediaGroup;
  };

  # services.jellyseer = {
  #   enable = true;
  #   port = 5055;
  # };

  services.sonarr = {
    enable = true;
    group = mediaGroup;
  };

  services.radarr = {
    enable = true;
    group = mediaGroup;
  };

  services.prowlarr = {
    enable = true;
  };

  services.bazarr = {
    enable = true;
    group = mediaGroup;
  };

  services.sabnzbd = {
    enable = true;
    group = mediaGroup;
  };
}
