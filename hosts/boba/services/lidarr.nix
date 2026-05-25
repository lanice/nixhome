{ pkgs, ... }:
let
  configDir = "/var/lib/lidarr-nightly";
  mediaDir = "/data/media";
  ytDlp = pkgs.buildEnv {
    name = "lidarr-ytdlp";
    paths = [ pkgs.yt-dlp pkgs.ffmpeg ];
    pathsToLink = [ "/bin" ];
  };
  bgutilPlugin = pkgs.fetchzip {
    url = "https://github.com/Brainicism/bgutil-ytdlp-pot-provider/releases/download/1.3.1/bgutil-ytdlp-pot-provider.zip";
    hash = "sha256-v4HgNGbC9ZBZoVi66EPjyu5bETD/jSyz/J/5PoTxpzM=";
    stripRoot = false;
  };
in {
  systemd.tmpfiles.rules = [
    "d ${configDir} 0770 1000 992 - -"
    "d /downloads/youtube 0770 1000 992 - -"
  ];

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
      PATH = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${ytDlp}/bin";
      YTDLP_PLUGIN_DIRS = "${bgutilPlugin}";
    };
    volumes = [
      "${configDir}:/config:rw"
      "${mediaDir}/music:/music:rw"
      "/downloads/soulseek:/downloads/soulseek:rw"
      "/downloads/usenet:/downloads/usenet:rw"
      "/downloads/youtube:/downloads/youtube:rw"
      "/nix/store:/nix/store:ro"
      "${ytDlp}/bin/ffmpeg:/usr/local/bin/ffmpeg:ro"
    ];
  };

  virtualisation.oci-containers.containers.bgutil-provider = {
    image = "brainicism/bgutil-ytdlp-pot-provider:latest";
    autoStart = true;
    ports = ["4416:4416"];
    extraOptions = ["--pull=newer"];
  };
}
