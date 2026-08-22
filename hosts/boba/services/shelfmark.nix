# Shelfmark: the acquisition layer for ebooks. Downloads land in BookOrbit's
# Book Dock (the `book-dock` share) and wait there for curation. Ebooks only
# while the audiobook platform is still being trialled.
{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: let
  media = config.homelab.media;
  pub = config.homelab.published;
  port = 8084;
  sabCompleteEbooks = media.shares."usenet/complete/ebooks".path;
in {
  # PROWLARR_API_KEY and SABNZBD_API_KEY.
  age.secrets.shelfmark.file = "${inputs.self}/secrets/shelfmark.age";

  # Sabnzbd's ebooks category dir. Shelfmark moves completed jobs out of it
  # itself — two writers, so a share. Declared here rather than by sabnzbd,
  # which has no reason to know this service exists.
  homelab.media.shares."usenet/complete/ebooks" = {
    under = "downloads";
    owner = "sabnzbd";
  };

  services.shelfmark = {
    enable = true;
    # Shelfmark 1.3.9 imports httpx unconditionally, but nixpkgs omitted its
    # declared httpx[http2] dependency. Remove once nixpkgs includes it.
    package = pkgs.shelfmark.overrideAttrs (old: {
      pythonPath = old.pythonPath ++ (with pkgs.python314Packages; [httpx h2]);
    });
    environment = {
      FLASK_PORT = port;
      AUTH_METHOD = "none";
      INGEST_DIR = media.shares."book-dock".path;
      PROWLARR_ENABLED = "true";
      PROWLARR_URL = "http://127.0.0.1:${toString pub.prowlarr.proxyTo}";
      PROWLARR_USENET_CLIENT = "sabnzbd";
      SABNZBD_URL = "http://127.0.0.1:${toString pub.sabnzbd.proxyTo}";
      SABNZBD_CATEGORY = "ebooks";
    };
  };

  systemd.services.shelfmark = {
    # ProtectSystem=strict carves the ReadWritePaths below out at namespace
    # setup, so /downloads (non-legacy ZFS) must be mounted first — see
    # navidrome in media.nix for why the ordering must be named.
    after = ["zfs-mount.service"];
    requires = ["zfs-mount.service"];

    # Gunicorn's control server writes $HOME/.gunicorn; a DynamicUser unit
    # has no home.
    environment.HOME = "/var/lib/shelfmark";

    serviceConfig = {
      # Primary group: a supplementary one would not survive the unit's
      # PrivateUsers=true (see bookorbit).
      Group = media.group;
      # The module's 0077 would make dock drops invisible to BookOrbit.
      UMask = lib.mkForce "0007";
      EnvironmentFile = config.age.secrets.shelfmark.path;
      ReadWritePaths = [
        media.shares."book-dock".path
        sabCompleteEbooks
      ];
    };
  };

  homelab.published.shelfmark.proxyTo = port;
}
