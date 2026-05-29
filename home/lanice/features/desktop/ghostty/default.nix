{
  config,
  lib,
  ...
}: {
  # GTK 4.20+ no longer handles compose/dead keys on Wayland without an IM;
  # COSMIC doesn't implement the required text-input protocol yet
  systemd.user.sessionVariables.GTK_IM_MODULE = "simple";

  # Ghostty 1.3.0+ honors this GTK setting for middle-click primary-selection
  # paste; it's unset by default here, so paste went silent. (COSMIC Terminal /
  # Alacritty ignore the setting, which is why they still work.)
  dconf.settings."org/gnome/desktop/interface".gtk-enable-primary-paste = true;

  programs.ghostty = {
    enable = true;
    settings = {
      theme = lib.mkDefault "Gruvbox Material";
      # theme = "Monokai Remastered";

      background-opacity = lib.mkDefault 0.8;

      cursor-style = "bar";
      cursor-style-blink = false;
      shell-integration-features = "no-cursor";

      quit-after-last-window-closed = false;

      window-height = 48;
      window-width = 160;
      window-inherit-working-directory = false;

      window-decoration = lib.mkDefault "none";
      window-padding-x = 2;
      window-padding-y = 2;
      window-padding-balance = true;

      gtk-single-instance = true;

      font-family = config.fontProfiles.monospace.family;
    };
  };
}
