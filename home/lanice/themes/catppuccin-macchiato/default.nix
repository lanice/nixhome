{
  lib,
  pkgs,
  ...
}: {
  theme.polarity = "dark";
  theme.cosmic.ronFile = ./cosmic-catppuccin-macchiato-green+slightlyround.ron;

  programs.vscode.profiles.default = {
    userSettings."workbench.colorTheme" = "Catppuccin Macchiato";
    userSettings."workbench.iconTheme" = "catppuccin-macchiato";
  };

  programs.btop.settings.color_theme = "catppuccin-macchiato";
  home.file.".config/btop/themes/catppuccin-macchiato.theme".source = ./btop-catppuccin-macchiato.theme;

  programs.ghostty.settings.theme = "Catppuccin Macchiato";
}
