{
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [inputs.catppuccin.homeModules.catppuccin];
  catppuccin = {
    enable = true;
    flavor = "latte";
    accent = "teal";

    firefox.enable = false;
    vscode.profiles.default.enable = false;
  };

  theme.polarity = "light";
  theme.cosmic.ronFile = ./cosmic-catppuccin-latte-green+slightlyround.ron;

  programs.vscode.profiles.default = {
    userSettings."workbench.colorTheme" = "Catppuccin Latte";
    userSettings."workbench.iconTheme" = "catppuccin-latte";
  };

  programs.ghostty.settings.theme = "Catppuccin Latte";
}
