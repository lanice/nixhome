# BookOrbit: the library layer for books — browse, curate metadata, read in
# the web reader, and sync to the KOReader Kindle. Downstream of nothing for
# now: books enter the estate's `books` share by hand (or via BookOrbit's web
# upload); audiobooks remain Audiobookshelf's alone.
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

  services.bookorbit = {
    enable = true;

    # The media group as primary group is what grants the 0770 shares. A
    # supplementary group would not survive the unit's PrivateUsers=true —
    # unmapped ids appear as nobody inside the user namespace — but the unit's
    # own group is mapped, so hardening and share access coexist.
    group = media.group;

    environment = {
      PORT = 3004;
      APP_URL = pub.bookorbit.url;
      # Start the in-app library folder picker at the estate's books share.
      LIBRARY_BROWSE_ROOT = media.shares.books.path;
    };

    # JWT_SECRET and SETUP_BOOTSTRAP_TOKEN.
    environmentFile = config.age.secrets.bookorbit.path;
  };

  homelab.published.bookorbit.proxyTo = config.services.bookorbit.environment.PORT;

  # The vendored module's UMask=0077 would make everything BookOrbit writes to
  # the books share 0600 bookorbit — invisible to the rest of the media group.
  # Group-rw keeps its writes co-accessible, which is the whole point of a share.
  systemd.services.bookorbit.serviceConfig.UMask = lib.mkForce "0007";
}
