{
  pkgs,
  lib,
  inputs,
  outputs,
  ...
}: {
  imports = [
    ./global # includes features/cli,features/helix
    ./features/email
    ./features/maestral
    ./features/distrobox
    ./features/desktop/firefox
    ./features/desktop/vscode
    ./features/desktop/alacritty
    ./features/desktop/wezterm
    ./features/desktop/office

    ./features/ottertune

    ./features/desktop/gnome
    # ./features/desktop/hyprland

    ./themes/catppuccin-frappe
  ];

  #  -------   ----------
  # | eDP-1 | | HDMI-1-0 |
  #  -------   ----------
  monitors = [
    {
      name = "eDP-1";
      width = 3840;
      # width = 1920;
      height = 2400;
      # height = 1200;
      scale = "1.5";
      x = 0;
      workspace = "2";
      primary = false;
    }
    {
      name = "HDMI-A-2";
      width = 3840;
      height = 1600;
      # x = 3840;
      x = 2560;
      workspace = "1";
      primary = true;
      # enabled = false;
    }
  ];

  home = {
    sessionVariables = {
      EDITOR = "hx";
      TERMINAL = "alacritty";
    };

    packages = with pkgs; [
      slack
      discord
      telegram-desktop
      zoom-us
      whatsapp-for-linux
      fractal

      google-chrome

      obsidian
      spotify
      gimp
      xournalpp
      zed-editor

      sxiv

      bitwarden

      xorg.xrandr
    ];

    stateVersion = lib.mkDefault "23.05"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  };
}
