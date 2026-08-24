# BookOrbit: the library layer for books — browse, curate metadata, read in
# the web reader, and sync to the KOReader Kindle. Downstream of shelfmark:
# downloads land in the Book Dock share and wait there for curation;
# audiobooks remain Audiobookshelf's alone.
#
# Runs from a module vendored out of an unmerged nixpkgs PR — see
# ./vendored-module.nix for provenance and the deviations taken.
{
  inputs,
  config,
  lib,
  ...
}: let
  media = config.homelab.media;
  pub = config.homelab.published;
in {
  imports = [./vendored-module.nix];

  age.secrets.bookorbit.file = "${inputs.self}/secrets/bookorbit.age";

  # The Book Dock, moved out of the state directory when shelfmark became a
  # second writer — two writers make it a share.
  homelab.media.shares."book-dock" = {
    under = "downloads";
    owner = "bookorbit";
  };

  services.bookorbit = {
    enable = true;

    # The media group as primary group is what grants the 0770 shares. A
    # supplementary group would not survive the unit's PrivateUsers=true —
    # unmapped ids appear as nobody inside the user namespace — but the unit's
    # own group is mapped, so hardening and share access coexist.
    inherit (media) group;
    # Preconfigured plugin downloads must use the Kindle-reachable LAN origin,
    # not the browser's tailnet-only published origin.
    koreaderPluginOrigin = "http://192.168.4.41:${toString config.services.bookorbit.environment.PORT}";

    environment = {
      PORT = 3004;
      APP_URL = pub.bookorbit.url;
      # Start the in-app library folder picker at the estate's books share.
      LIBRARY_BROWSE_ROOT = media.shares.books.path;
      BOOK_DOCK_PATH = media.shares."book-dock".path;
    };

    # JWT_SECRET and SETUP_BOOTSTRAP_TOKEN.
    environmentFile = config.age.secrets.bookorbit.path;
  };

  homelab.published.bookorbit.proxyTo = config.services.bookorbit.environment.PORT;

  # The KOReader plugin on the Kindle (home WiFi, no Tailscale) can't reach
  # the tailnet-only published URL, so it gets the raw port on the LAN
  # interface instead — not a published service: no subdomain, no TLS. The
  # published HTTPS URL stays canonical for everything else; the Kindle is
  # configured with http://<boba's reserved LAN IP>:<port> directly.
  networking.firewall.interfaces."enp95s0".allowedTCPPorts = [
    config.services.bookorbit.environment.PORT
  ];

  systemd.services.bookorbit = {
    # The dock watcher inotifies /downloads (non-legacy ZFS) at bootstrap;
    # started pre-mount it would watch the stub's inode and stay blind once
    # the real dataset arrives over it (see navidrome in media.nix).
    after = ["zfs-mount.service"];
    requires = ["zfs-mount.service"];

    # The vendored module's UMask=0077 would make everything BookOrbit writes
    # to the books share 0600 bookorbit — invisible to the rest of the media
    # group. Group-rw keeps its writes co-accessible, which is the whole
    # point of a share.
    serviceConfig.UMask = lib.mkForce "0007";
  };
}
