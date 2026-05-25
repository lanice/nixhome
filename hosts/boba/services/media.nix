let
  mediaGroup = "multimedia";
  mediaDir = "/data/media";
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
    "d ${mediaDir}/audiobooks 0770 - ${mediaGroup} - -"
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

  # Old v3 Lidarr kept on a side port so settings can be copied into the
  # nightly container (different DB schema, so no in-place upgrade). Remove
  # this block once migration is done.
  services.lidarr = {
    enable = true;
    group = mediaGroup;
    settings.server.port = 8687;
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

  services.navidrome = {
    enable = true;
    group = mediaGroup;
    settings = {
      MusicFolder = "${mediaDir}/music";
      # Bind on all interfaces so containers can reach it via the podman bridge.
      # LAN exposure is gated by the firewall (port 4533 only opened on podman0).
      Address = "0.0.0.0";
    };
  };

  services.audiobookshelf = {
    enable = true;
    group = mediaGroup;
    port = 8588;
  };
}
