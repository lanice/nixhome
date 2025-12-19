{
  pkgs,
  config,
  ...
}: let
  inherit (config) fontProfiles;
in {
  imports = [
    ../common
    ./extensions
  ];

  services.xsettingsd.enable = false; # To overwrite the default (enable = true) from gtk.nix

  dconf.settings = {
    "org/gnome/shell" = {
      favorite-apps = [
        "firefox.desktop"
        "code.desktop"
        "com.mitchellh.ghostty.desktop"
        "slack.desktop"
        "thunderbird.desktop"
        "org.telegram.desktop.desktop"
        "discord.desktop"
        "org.gnome.Nautilus.desktop"
      ];
    };

    "org/gnome/desktop/interface" = {
      enable-hot-corners = false;
      # cursor-size = 33;

      font-name = "${fontProfiles.sansSerif.family} 12";
      document-font-name = "${fontProfiles.serif.family} 11";
      monospace-font-name = "${fontProfiles.monospace.family} 12";
    };

    "org/gnome/mutter" = {
      workspaces-only-on-primary = true;
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-terminal/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-wofi/"
      ];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-terminal" = {
      binding = "<Super>Return";
      command = "ghostty +new-window";
      name = "open-terminal";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-wofi" = {
      binding = "<Super>D";
      command = "wofi -S drun -x 10 -y 10 -W 45% -H 40%";
      name = "wofi-drun";
    };
  };
}
