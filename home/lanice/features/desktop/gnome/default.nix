{pkgs, ...}: {
  imports = [
    ../common
    ../common/wayland-wm/wofi.nix
    ./extensions
  ];

  services.xsettingsd.enable = false; # To overwrite the default (enable = true) from gtk.nix

  dconf.settings = {
    "org/gnome/shell" = {
      favorite-apps = [
        "firefox.desktop"
        "code.desktop"
        "Alacritty.desktop"
        "slack.desktop"
        "thunderbird.desktop"
        "org.telegram.desktop.desktop"
        "discord.desktop"
        "spotify.desktop"
        "org.gnome.Nautilus.desktop"
      ];
    };

    "org/gnome/desktop/interface" = {
      enable-hot-corners = false;
      # cursor-size = 33;
    };

    "org/gnome/mutter" = {
      workspaces-only-on-primary = true;
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-alacritty/"
        # "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-rofi/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-wofi/"
      ];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-alacritty" = {
      binding = "<Super>Return";
      command = "alacritty";
      name = "open-terminal";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-rofi" = {
      binding = "<Super>D";
      command = "rofi -show drun";
      name = "rofi-drun";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-wofi" = {
      binding = "<Super>D";
      command = "wofi -S drun -x 10 -y 10 -W 45% -H 40%";
      name = "wofi-drun";
    };
  };
}
