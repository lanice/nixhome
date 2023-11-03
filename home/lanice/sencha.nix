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
    ./features/desktop/gnome
    #    ./features/desktop/hyprland
    ./features/desktop/firefox
    ./features/desktop/vscode
    ./features/desktop/alacritty
  ];

  colorscheme = inputs.nix-colors.colorschemes.gigavolt;
  wallpaper = outputs.wallpapers.watercolor-beach;

  #  -------   ----------
  # | eDP-1 | | HDMI-1-0 |
  #  -------   ----------
  #  monitors = [
  #    {
  #      name = "eDP-1";
  #      width = 2560;
  #      height = 1600;
  #      x = 0;
  #      workspace = "1";
  #      primary = true;
  #    }
  #    {
  #      name = "HDMI-A-1";
  #      width = 3840;
  #      height = 1600;
  #      x = 2560;
  #      workspace = "2";
  #      primary = false;
  #      # enabled = false;
  #    }
  #  ];

  home = {
    sessionVariables = {
      EDITOR = "vim";
      TERMINAL = "alacritty";
    };

    packages = with pkgs; [
      slack
      discord
      telegram-desktop

      obsidian
      spotify
      gimp

      bitwarden

      xorg.xrandr
    ];

    stateVersion = lib.mkDefault "23.05"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  };
}
