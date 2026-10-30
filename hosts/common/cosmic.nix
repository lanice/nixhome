{
  lib,
  config,
  pkgs,
  ...
}: {
  options.desktops.cosmic.enable = lib.mkEnableOption "Cosmic desktop environment";

  config = lib.mkIf config.desktops.cosmic.enable {
    # Backport recording clock fix; remove once nixpkgs ships Kooha 2.3.2.
    nixpkgs.overlays = [
      (final: prev: {
        kooha = prev.kooha.overrideAttrs (old: {
          patches =
            (old.patches or [])
            ++ lib.optional (lib.versionOlder old.version "2.3.2") (final.fetchurl {
              url = "https://github.com/SeaDve/Kooha/commit/7e940a9b6e3a5557e271d2fd5ecc6cf079e4f5dc.patch";
              hash = "sha256-GYzo7DRrS/qTThJnQnPTvuCy2U72MA8a1bHOHpr5ZUU=";
            });
        });
        # Screencast crash ("create_frame sent before the previous frame was destroyed");
        # remove once pop-os/cosmic-protocols#92 lands in a portal release.
        xdg-desktop-portal-cosmic = prev.xdg-desktop-portal-cosmic.overrideAttrs (old: {
          postPatch =
            (old.postPatch or "")
            + ''
              for d in "$cargoDepsCopy"/*/cosmic-client-toolkit-*; do
                patch -d "$d" -p2 < ${final.fetchpatch {
                url = "https://github.com/pop-os/cosmic-protocols/commit/3ad1781fefeaea5224ec6917f53ccad32bf5219b.patch";
                hash = "sha256-LSXaTdy5fyFSevhxdEviE6BHN8B+aa3csKNsrvx2GZE=";
              }}
              done
            '';
        });
      })
    ];

    services.xserver.xkb = {
      layout = "us";
      variant = "altgr-intl";
    };

    services.displayManager.cosmic-greeter.enable = true;

    services.desktopManager.cosmic.enable = true;
    services.desktopManager.cosmic.xwayland.enable = true;

    services.system76-scheduler.enable = true;

    environment.cosmic.excludePackages = with pkgs; [
      # cosmic-edit
      # cosmic-term
    ];
  };
}
