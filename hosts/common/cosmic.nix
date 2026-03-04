{pkgs, ...}: {
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

  # https://wiki.nixos.org/wiki/COSMIC#Clipboard
  environment.sessionVariables.COSMIC_DATA_CONTROL_ENABLED = 1;
}
