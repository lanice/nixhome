{ pkgs, ... }:
let
  mediaGroup = "multimedia";
  mediaDir = "/data/media";
  lidarrConfigDir = "/var/lib/lidarr-nightly";
  lidarrYtDlp = pkgs.buildEnv {
    name = "lidarr-ytdlp";
    paths = [ pkgs.yt-dlp pkgs.ffmpeg ];
    pathsToLink = [ "/bin" ];
  };
  bgutilYtdlpPlugin = pkgs.fetchzip {
    url = "https://github.com/Brainicism/bgutil-ytdlp-pot-provider/releases/download/1.3.1/bgutil-ytdlp-pot-provider.zip";
    hash = "sha256-v4HgNGbC9ZBZoVi66EPjyu5bETD/jSyz/J/5PoTxpzM=";
    stripRoot = false;
  };
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
    "d /downloads/youtube 0770 1000 992 - -"
    "d ${mediaDir}/audiobooks 0770 - ${mediaGroup} - -"
    "d ${lidarrConfigDir} 0770 1000 992 - -"
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

  # Lidarr's plugin system (required by Tubifarry for slskd, lyrics, etc.) lives
  # only in the "nightly" / plugins branch — nixpkgs ships the legacy v3 main
  # branch with no plugin support, so we run the linuxserver container instead.
  virtualisation.oci-containers.containers.lidarr = {
    image = "lscr.io/linuxserver/lidarr:nightly";
    autoStart = true;
    ports = ["8686:8686"];
    environment = {
      PUID = "1000";
      PGID = "992"; # multimedia group
      TZ = "America/New_York";
      PATH = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${lidarrYtDlp}/bin";
      YTDLP_PLUGIN_DIRS = "${bgutilYtdlpPlugin}";
    };
    volumes = [
      "${lidarrConfigDir}:/config:rw"
      "${mediaDir}/music:/music:rw"
      "/downloads/soulseek:/downloads/soulseek:rw"
      "/downloads/usenet:/downloads/usenet:rw"
      "/downloads/youtube:/downloads/youtube:rw"
      "/nix/store:/nix/store:ro"
      "${lidarrYtDlp}/bin/ffmpeg:/usr/local/bin/ffmpeg:ro"
    ];
  };

  virtualisation.oci-containers.containers.bgutil-provider = {
    image = "brainicism/bgutil-ytdlp-pot-provider:latest";
    autoStart = true;
    ports = ["4416:4416"];
    extraOptions = ["--pull=newer"];
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
