{
  lib,
  pkgs,
  ...
}: {
  imports = [../common.nix];

  theme.polarity = "dark";

  programs.vscode.profiles.default = {
    userSettings."workbench.colorTheme" = "Catppuccin Frappé";
    userSettings."workbench.iconTheme" = "catppuccin-frappe";
  };

  programs.btop.settings = {
    color_theme = lib.mkForce "catppuccin-frappe";
  };
  home.file.".config/btop/themes/catppuccin-frappe.theme".source = ./btop-catppuccin-frappe.theme;

  programs.rofi.theme = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/catppuccin/rofi/main/basic/.local/share/rofi/themes/catppuccin-frappe.rasi";
    sha256 = "sha256:0zvb8v10alypwzd8i2r8izy4vy150jxnnv3frvvhwxsvm8d7lifm";
  };
}
