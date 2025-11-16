let
  configDir = "/var/lib/calibre-web";
  ingestDir = "/downloads/cwa-book-ingest";
  libraryDir = "/data/media/books";
in {
  systemd.tmpfiles.rules = [
    "d ${configDir} 0770 1000 1000 - -"
    "d ${ingestDir} 0770 - multimedia - -"
    "d ${libraryDir} 0770 - multimedia - -"
  ];

  virtualisation.oci-containers.containers = {
    calibre-web-automated = {
      image = "crocodilestick/calibre-web-automated:latest";
      ports = ["8083:8083"];
      autoStart = true;
      environment = {
        "PUID" = "1000";
        "PGID" = "992"; # group ID for multimedia group
        "TZ" = "America/New_York";
      };
      volumes = [
        "${configDir}:/config:rw"
        "${ingestDir}:/cwa-book-ingest:rw"
        "${libraryDir}:/calibre-library:rw"
      ];

      extraOptions = ["--pull=newer"];
    };

    calibre-web-automated-book-downloader = {
      image = "ghcr.io/calibrain/calibre-web-automated-book-downloader:latest";
      ports = ["8084:8084"];
      autoStart = true;
      environment = {
        "PUID" = "1000";
        "PGID" = "992"; # group ID for multimedia group
        "TZ" = "America/New_York";

        "UID" = "1000";
        "GID" = "992";
      };
      volumes = ["${ingestDir}:/cwa-book-ingest:rw"];

      extraOptions = ["--pull=newer"];
    };
  };
}
