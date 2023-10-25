{
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    ./global # includes features/cli/default.nix
    ./features/desktop/hyprland
    ./features/desktop/alacritty
    ./features/desktop/common/font.nix
  ];

  colorscheme = inputs.nix-colors.colorschemes.tokyo-night-storm;

  home = {
    sessionVariables = {
      EDITOR = "vim";
      TERMINAL = "alacritty";
    };

    packages = with pkgs; [
      firefox
      vscode

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
