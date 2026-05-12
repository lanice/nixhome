let
  dataDir = "/var/lib/tracearr";
in {
  systemd.tmpfiles.rules = [
    "d ${dataDir} 0750 - - -"
    "d ${dataDir}/postgres 0750 - - -"
    "d ${dataDir}/redis 0750 - - -"
    "d ${dataDir}/data 0750 - - -"
  ];

  # The Jellyfin server URL is configured in Tracearr's web UI (stored in
  # its postgres DB, not here). Set it to http://host.containers.internal:8096
  # — pointing at the public hostname routes via Tailscale, which the podman
  # bridge can't reach (Tailscale's ts-input chain drops !tailscale0 → CGNAT).
  virtualisation.oci-containers.containers.tracearr = {
    image = "ghcr.io/connorgallopo/tracearr:supervised";
    autoStart = true;
    ports = ["3000:3000"];

    environment = {
      TZ = "America/New_York";
      LOG_LEVEL = "info";
    };

    volumes = [
      "${dataDir}/postgres:/data/postgres:rw"
      "${dataDir}/redis:/data/redis:rw"
      "${dataDir}/data:/data/tracearr:rw"
    ];

    extraOptions = [
      "--pull=newer"
      "--shm-size=512m"
      "--memory=3g"
      "--ulimit=nofile=65536:65536"
    ];
  };
}
