{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [../stylix.nix];

  config.theme = "catppuccin-latte";

  config.home-manager.users.lanice = {
    programs.vscode = {
      userSettings.workbench.colorTheme = lib.mkForce "Catppuccin Latte";
      userSettings.workbench.iconTheme = lib.mkForce "catppuccin-latte";
      extensions = with pkgs.vscode-extensions; [
        catppuccin.catppuccin-vsc
        catppuccin.catppuccin-vsc-icons
      ];
    };

    programs.btop.settings = {
      color_theme = lib.mkForce "catppuccin-latte";
    };
    home.file.".config/btop/themes/catppuccin-latte.theme".source = ./btop-catppuccin-latte.theme;
  };
}
