let
  mediaDir = "/data/media";
  mediaGroup = "multimedia";
in {
  users.users.lanice.extraGroups = [mediaGroup];

  users.groups.${mediaGroup} = {};

  systemd.tmpfiles.rules = [
    "d ${mediaDir} 0770 root ${mediaGroup} - -"
    "d ${mediaDir}/movies 0770 - ${mediaGroup} - -"
    "d ${mediaDir}/shows 0770 - ${mediaGroup} - -"
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
}
