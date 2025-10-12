let
  mediaGroup = "multimedia";
  mediaDir = "/data/media";
  downloadDir = "/downloads/usenet";
in {
  users.users.lanice.extraGroups = [mediaGroup];

  users.groups.${mediaGroup} = {};

  systemd.tmpfiles.rules = [
    "d ${mediaDir} 0770 root ${mediaGroup} - -"
    "d ${mediaDir}/movies 0770 - ${mediaGroup} - -"
    "d ${mediaDir}/shows 0770 - ${mediaGroup} - -"
    "d ${mediaDir}/anime 0770 - ${mediaGroup} - -"
    "d ${mediaDir}/books 0770 - ${mediaGroup} - -"
    "d ${mediaDir}/music 0770 - ${mediaGroup} - -"
    "d ${downloadDir} 0770 sabnzbd ${mediaGroup} - -"
    "d ${downloadDir}/incomplete 0770 sabnzbd ${mediaGroup} - -"
    "d ${downloadDir}/complete 0770 sabnzbd ${mediaGroup} - -"
  ];

  services.jellyfin = {
    enable = true;
    group = mediaGroup;
    openFirewall = true;
  };

  services.jellyseerr = {
    enable = true;
    port = 5055;
  };

  services.sonarr = {
    enable = true;
    group = mediaGroup;
  };

  services.radarr = {
    enable = true;
    group = mediaGroup;
  };

  services.lidarr = {
    enable = true;
    group = mediaGroup;
  };

  services.readarr = {
    enable = true;
    group = mediaGroup;
  };

  services.bazarr = {
    enable = true;
    group = mediaGroup;
  };

  services.prowlarr = {
    enable = true;
  };

  services.nzbhydra2 = {
    enable = true;
  };

  services.sabnzbd = {
    enable = true;
    group = mediaGroup;
  };

  services.navidrome = {
    enable = true;
    group = mediaGroup;
    settings = {
      MusicFolder = "${mediaDir}/music";
    };
  };
}
