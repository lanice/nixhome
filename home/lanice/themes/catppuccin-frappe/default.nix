{
  lib,
  pkgs,
  ...
}: {
  theme.polarity = "dark";
  theme.cosmic.ronFile = ./cosmic-catppuccin-frappe-green+slightlyround.ron;

  programs.vscode.profiles.default = {
    userSettings."workbench.colorTheme" = "Catppuccin Frappé";
    userSettings."workbench.iconTheme" = "catppuccin-frappe";
  };

  programs.btop.settings.color_theme = "catppuccin-frappe";
  home.file.".config/btop/themes/catppuccin-frappe.theme".source = ./btop-catppuccin-frappe.theme;

  programs.ghostty.settings.theme = "Catppuccin Frappe";
}
