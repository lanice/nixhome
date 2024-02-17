{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [../stylix.nix];

  config.theme = "catppuccin-frappe";

  config.home-manager.users.lanice = {
    stylix.targets.vscode.enable = false;
    programs.vscode = {
      userSettings."workbench.colorTheme" = "Catppuccin Frappé";
      userSettings."workbench.iconTheme" = "catppuccin-frappe";
    };

    programs.btop.settings = {
      color_theme = lib.mkForce "catppuccin-frappe";
    };
    home.file.".config/btop/themes/catppuccin-frappe.theme".source = ./btop-catppuccin-frappe.theme;
  };
}
