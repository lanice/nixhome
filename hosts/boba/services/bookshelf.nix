{config, ...}: let
  media = config.homelab.media;
  configDir = "/var/lib/bookshelf";
  bookDir = media.shares.books.path;
  audiobookDir = media.shares.audiobooks.path;
  dropDir = media.shares."usenet/complete/bookshelf".path;
in {
  systemd.tmpfiles.rules = [
    "d ${configDir} 0770 ${media.owner} ${media.group} - -"
  ];

  # Bookshelf's drop directory inside sabnzbd's completed tree. Declared here
  # rather than by sabnzbd, which has no reason to know this service exists.
  homelab.media.shares."usenet/complete/bookshelf" = {
    under = "downloads";
    owner = "sabnzbd";
  };

  virtualisation.oci-containers.containers = {
    bookshelf = {
      image = "ghcr.io/pennydreadful/bookshelf:hardcover";
      ports = ["${toString config.homelab.published.bookshelf.proxyTo}:8787"];
      autoStart = true;
      environment = {
        "PUID" = toString media.uid;
        "PGID" = toString media.gid;
        "TZ" = "America/New_York";
      };
      volumes = [
        "${configDir}:/config:rw"
        "${dropDir}:${dropDir}:rw"
        "${bookDir}:/books:rw"
        "${audiobookDir}:/audiobooks:rw"
      ];
      networks = ["host"];
    };
  };

  homelab.published.bookshelf.proxyTo = 8787;
}
