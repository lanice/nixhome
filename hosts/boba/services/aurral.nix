{config, ...}: let
  media = config.homelab.media;
  configDir = "/var/lib/aurral";
  downloadDir = media.shares."music/aurral".path;
in {
  systemd.tmpfiles.rules = [
    "d ${configDir} 0770 ${media.owner} ${media.group} - -"
  ];

  homelab.media.shares."music/aurral" = {
    under = "media";
    inherit (media) owner;
  };

  # Music request frontend (Jellyseerr-equivalent). Orchestrates Lidarr + slskd
  # and surfaces a request UI. Connections to Lidarr/Navidrome/slskd are wired
  # in the web UI at http://boba:3001/.
  virtualisation.oci-containers.containers.aurral = {
    image = "ghcr.io/lklynet/aurral:latest";
    autoStart = true;
    # Host port shifted off 3001 (uptime-kuma) — container still listens on 3001 internally.
    ports = ["${toString config.homelab.published.aurral.proxyTo}:3001"];
    environment = {
      PUID = toString media.uid;
      PGID = toString media.gid;
      TZ = "America/New_York";
    };
    volumes = [
      "${configDir}:/app/backend/data:rw"
      "${downloadDir}:/app/downloads:rw"
    ];
    extraOptions = ["--pull=newer"];
  };

  homelab.published.aurral.proxyTo = 3002;
}
