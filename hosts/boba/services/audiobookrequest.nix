let
  configDir = "/var/lib/audiobookrequest";
in {
  systemd.tmpfiles.rules = [
    "d ${configDir} 0770 1000 1000 - -"
  ];

  virtualisation.oci-containers.containers = {
    audiobookrequest = {
      image = "markbeep/audiobookrequest:latest";
      ports = ["8799:8000"];
      autoStart = true;
      environment = {
        "PUID" = "1000";
        "PGID" = "992"; # group ID for multimedia group
        "TZ" = "America/New_York";
      };
      volumes = [
        "${configDir}:/config:rw"
      ];
    };
  };
}
