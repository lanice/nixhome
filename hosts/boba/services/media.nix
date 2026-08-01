{config, ...}: let
  media = config.homelab.media;
  mediaGroup = media.group;
in {
  services.jellyfin = {
    enable = true;
    group = mediaGroup;
    openFirewall = true;
  };

  services.seerr = {
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
      MusicFolder = media.shares.music.path;
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

  homelab.published = {
    jellyfin = {
      subdomain = "watch";
      # nixpkgs' jellyfin module exposes no port option — 8096 is fixed by the
      # upstream package, so this is the only place it can be written.
      proxyTo = 8096;
    };

    seerr = {
      subdomain = "browse";
      proxyTo = config.services.seerr.port;
    };

    navidrome = {
      subdomain = "music";
      proxyTo = config.services.navidrome.settings.Port;
    };

    audiobookshelf.proxyTo = config.services.audiobookshelf.port;
    sonarr.proxyTo = config.services.sonarr.settings.server.port;
    radarr.proxyTo = config.services.radarr.settings.server.port;
    bazarr.proxyTo = config.services.bazarr.listenPort;
    prowlarr.proxyTo = config.services.prowlarr.settings.server.port;
    # As with jellyfin, nixpkgs' nzbhydra2 module exposes no port option.
    nzbhydra.proxyTo = 5076;

    # Old v3 Lidarr, see the services.lidarr comment above.
    lidarr-old.proxyTo = config.services.lidarr.settings.server.port;
  };
}
