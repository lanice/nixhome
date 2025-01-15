{
  lib,
  pkgs,
  ...
}: {
  imports = [../stylix.nix];

  stylix = {
    base16Scheme = ./base16.yaml;
    polarity = "dark";

    image = pkgs.fetchurl {
      url = "https://i.postimg.cc/TGrLzsD8/dogsplayingpoker.png";
      sha256 = "sha256-51c5vQfcfD73BEdqfNxOcEkpgFSHC6u4eMqOVKJq9SY=";
    };

    cursor = {
      name = "catppuccin-frappe-dark-cursors";
      package = pkgs.catppuccin-cursors.frappeDark;
    };

    targets.vscode.enable = false;
    targets.rofi.enable = false;
  };

  programs.vscode = {
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
