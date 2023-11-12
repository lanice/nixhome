{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [../stylix.nix];

  config.theme = "catppuccin-frappe";

  config.home-manager.users.lanice = {
    programs.vscode = {
      userSettings.workbench.colorTheme = lib.mkForce "Catppuccin Frappé";
      userSettings.workbench.iconTheme = lib.mkForce "catppuccin-frappe";
      extensions = with pkgs.vscode-extensions; [
        catppuccin.catppuccin-vsc
        catppuccin.catppuccin-vsc-icons
      ];
    };

    programs.btop.settings = {
      color_theme = lib.mkForce "catppuccin-frappe";
    };
    home.file.".config/btop/themes/catppuccin-frappe.theme".source = ./btop-catppuccin-frappe.theme;
  };
}
