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
