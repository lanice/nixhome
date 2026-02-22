{
  lib,
  pkgs,
  ...
}: {
  theme.polarity = "light";

  programs.vscode.profiles.default = {
    userSettings."workbench.colorTheme" = "Catppuccin Latte";
    userSettings."workbench.iconTheme" = "catppuccin-latte";
  };

  programs.btop.settings.color_theme = lib.mkForce "catppuccin-latte";
  home.file.".config/btop/themes/catppuccin-latte.theme".source = ./btop-catppuccin-latte.theme;
}
