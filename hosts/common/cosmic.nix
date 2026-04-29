{
  lib,
  config,
  pkgs,
  ...
}: {
  options.desktops.cosmic.enable = lib.mkEnableOption "Cosmic desktop environment";

  config = lib.mkIf config.desktops.cosmic.enable {
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
