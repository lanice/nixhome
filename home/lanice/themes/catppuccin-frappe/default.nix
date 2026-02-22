{
  lib,
  pkgs,
  ...
}: {
  theme.polarity = "dark";

  programs.vscode.profiles.default = {
    userSettings."workbench.colorTheme" = "Catppuccin Frappé";
    userSettings."workbench.iconTheme" = "catppuccin-frappe";
  };

  programs.btop.settings = color_theme = lib.mkForce "catppuccin-frappe";
  home.file.".config/btop/themes/catppuccin-frappe.theme".source = ./btop-catppuccin-frappe.theme;
}
