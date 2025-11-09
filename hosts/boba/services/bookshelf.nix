let
  configDir = "/var/lib/bookshelf";
  bookDir = "/data/media/books";
  audiobookDir = "/data/media/audiobooks";
in {
  systemd.tmpfiles.rules = [
    "d ${configDir} 0770 1000 1000 - -"
  ];

  virtualisation.oci-containers.containers = {
    bookshelf = {
      image = "ghcr.io/pennydreadful/bookshelf:hardcover";
      ports = ["8787:8787"];
      autoStart = true;
      environment = {
        "PUID" = "1000";
        "PGID" = "992"; # group ID for multimedia group
        "TZ" = "America/New_York";
      };
      volumes = [
        "${configDir}:/config:rw"
        "/downloads/usenet/complete/bookshelf:/downloads/usenet/complete/bookshelf:rw"
        "${bookDir}:/books:rw"
        "${audiobookDir}:/audiobooks:rw"
      ];
      networks = ["host"];
    };
  };
}
