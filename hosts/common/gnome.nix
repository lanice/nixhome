{
  services.xserver = {
    enable = true;

    desktopManager.gnome.enable = true;

    displayManager = {
      gdm.enable = true;
      gdm.autoSuspend = false;

      autoLogin.enable = true;
      autoLogin.user = "lanice";
    };

    layout = "us";
    xkbVariant = "intl";
  };

  environment = {
    enableAllTerminfo = true;
    sessionVariables.TERMINAL = ["alacritty"];
    # gnome.excludePackages = with pkgs; [
    #   gnome-console
    # ];
  };

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;
}
