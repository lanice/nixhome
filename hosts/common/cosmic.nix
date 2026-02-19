{pkgs, ...}: {
  services.xserver.xkb = {
    layout = "us";
    variant = "intl";
  };

  services.displayManager.cosmic-greeter.enable = true;

  services.desktopManager.cosmic.enable = true;
  services.desktopManager.cosmic.xwayland.enable = true;

  environment.cosmic.excludePackages = with pkgs; [
    cosmic-edit
    cosmic-term
  ];
}
