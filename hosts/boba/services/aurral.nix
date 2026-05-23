let
  configDir = "/var/lib/aurral";
  mediaDir = "/data/media";
in {
  systemd.tmpfiles.rules = [
    "d ${configDir} 0770 1000 992 - -"
    "d ${mediaDir}/music/aurral 0770 1000 992 - -"
  ];

  # Music request frontend (Jellyseerr-equivalent). Orchestrates Lidarr + slskd
  # and surfaces a request UI. Connections to Lidarr/Navidrome/slskd are wired
  # in the web UI at http://boba:3001/.
  virtualisation.oci-containers.containers.aurral = {
    image = "ghcr.io/lklynet/aurral:latest";
    autoStart = true;
    # Host port shifted off 3001 (uptime-kuma) — container still listens on 3001 internally.
    ports = ["3002:3001"];
    environment = {
      PUID = "1000";
      PGID = "992";
      TZ = "America/New_York";
    };
    volumes = [
      "${configDir}:/app/backend/data:rw"
      "${mediaDir}/music/aurral:/app/downloads:rw"
    ];
    extraOptions = ["--pull=newer"];
  };
}
