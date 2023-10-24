{
  services.xserver = {
    enable = true;

    desktopManager.gnome.enable = true;

    displayManager = {
      gdm.enable = true;
      gdm.autoSuspend = false;
    };

    layout = "us";
    xkbVariant = "intl";
  };

  environment = {
    enableAllTerminfo = true;
    # sessionVariables.TERMINAL = ["alacritty"];
    # gnome.excludePackages = with pkgs; [
    #   gnome-console
    # ];
  };
}
