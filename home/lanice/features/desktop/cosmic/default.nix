{...}: {
  imports = [
    ../common
    ./comp.nix
    ./shortcuts.nix
    ./panel.nix
    ./dock.nix
    ./idle.nix
  ];

  services.xsettingsd.enable = false;

  # COSMIC config (RON format)
  # Managed declaratively — GUI changes won't persist across home-manager switch

  # Theme: catppuccin frappe (dark) / latte (light)
  # Import via COSMIC Settings > Appearance > Import using files in ./themes/
  # Theme paths are NOT managed declaratively (too many derived color files),
  # so imported themes persist across home-manager switches.

  # NOTE: If fullscreen causes black screen on external monitor, disable adaptive sync:
  # https://github.com/pop-os/cosmic-epoch/issues/2912
}
