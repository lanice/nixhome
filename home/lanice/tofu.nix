{
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    ./global # includes features/cli,features/helix
    ./features/desktop/hyprland
    ./features/desktop/firefox
    ./features/desktop/vscode
    ./features/desktop/alacritty
  ];

  colorscheme = inputs.nix-colors.colorschemes.tokyo-night-storm;
  wallpaper = outputs.wallpapers.watercolor-beach;

  monitors = [
    {
      name = "eDP-1";
      width = 1600;
      height = 900;
      workspace = "1";
      primary = true;
    }
  ];

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
    ];

    stateVersion = lib.mkDefault "23.05"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  };
}
