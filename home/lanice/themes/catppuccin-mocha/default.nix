{
  lib,
  pkgs,
  ...
}: {
  theme.polarity = "dark";
  theme.cosmic.ronFile = ./cosmic-catppuccin-mocha-green+slightlyround.ron;

  programs.vscode.profiles.default = {
    userSettings."workbench.colorTheme" = "Catppuccin Mocha";
    userSettings."workbench.iconTheme" = "catppuccin-mocha";
  };

  programs.btop.settings.color_theme = "catppuccin-mocha";
  home.file.".config/btop/themes/catppuccin-mocha.theme".source = ./btop-catppuccin-mocha.theme;

  programs.ghostty.settings.theme = "Catppuccin Mocha";
}
