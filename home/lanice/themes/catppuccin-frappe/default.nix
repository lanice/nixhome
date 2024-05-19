{
  lib,
  pkgs,
  ...
}: {
  imports = [../stylix.nix];

  theme = "catppuccin-frappe";

  stylix.targets.vscode.enable = false;
  programs.vscode = {
    userSettings."workbench.colorTheme" = "Catppuccin Frappé";
    userSettings."workbench.iconTheme" = "catppuccin-frappe";
  };

  programs.btop.settings = {
    color_theme = lib.mkForce "catppuccin-frappe";
  };
  home.file.".config/btop/themes/catppuccin-frappe.theme".source = ./btop-catppuccin-frappe.theme;
}
