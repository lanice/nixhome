{inputs, ...}: {
  imports = [
    inputs.cosmic-manager.homeManagerModules.cosmic-manager

    ../common
    ./comp.nix
    ./shortcuts.nix
    ./panel.nix
    ./dock.nix
    ./idle.nix
  ];

  wayland.desktopManager.cosmic.enable = true;

  services.xsettingsd.enable = false;

  # Theme: catppuccin frappe (dark) / latte (light)
  # Import via COSMIC Settings > Appearance > Import using files in ./themes/
  # Theme paths are NOT managed declaratively (too many derived color files),
  # so imported themes persist across home-manager switches.

  # NOTE: If fullscreen causes black screen on external monitor, disable adaptive sync:
  # https://github.com/pop-os/cosmic-epoch/issues/2912
}
