{
  lib,
  pkgs,
  ...
}: {
  theme.polarity = "light";
  theme.cosmic.ronFile = ./cosmic-catppuccin-latte-green+slightlyround.ron;

  programs.vscode.profiles.default = {
    userSettings."workbench.colorTheme" = "Catppuccin Latte";
    userSettings."workbench.iconTheme" = "catppuccin-latte";
  };

  programs.btop.settings.color_theme = "catppuccin-latte";
  home.file.".config/btop/themes/catppuccin-latte.theme".source = ./btop-catppuccin-latte.theme;

  programs.ghostty.settings.theme = "Catppuccin Latte";
}
