{pkgs, ...}: {
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
        "Alacritty.desktop"
        "thunderbird.desktop"
        "org.telegram.desktop.desktop"
        "spotify.desktop"
        "org.gnome.Nautilus.desktop"
      ];
    };

    "org/gnome/desktop/interface" = {
      enable-hot-corners = false;
      cursor-size = 33;
    };

    "org/gnome/mutter" = {
      workspaces-only-on-primary = true;
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      ];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super>Return";
      command = "alacritty";
      name = "open-terminal";
    };
  };
}
