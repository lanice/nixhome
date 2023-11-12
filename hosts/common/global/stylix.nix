{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: let
  theme = config.theme;

  themePath = "../../../../themes/" + theme + "/";
  scheme = themePath + theme + ".yaml";
  themePolarity = lib.removeSuffix "\n" (builtins.readFile (./. + themePath + "/polarity.txt"));
  backgroundUrl = builtins.readFile (./. + themePath + "/backgroundurl.txt");
  backgroundSha256 = builtins.readFile (./. + themePath + "/backgroundsha256.txt");
in {
  imports = [inputs.stylix.nixosModules.stylix];

  stylix = {
    base16Scheme = ./. + scheme;
    polarity = themePolarity;

    image = pkgs.fetchurl {
      url = backgroundUrl;
      sha256 = backgroundSha256;
    };

    # image = ../../../themes/background.webp;

    fonts = {
      monospace = {
        name = "GoMono Nerd Font Mono";
        package = pkgs.nerdfonts.override {fonts = ["Go-Mono"];}; # https://github.com/NixOS/nixpkgs/blob/master/pkgs/data/fonts/nerdfonts/shas.nix;
      };
      serif = {
        name = "Iosevka Etoile";
        package = pkgs.iosevka-bin.override {variant = "etoile";};
      };
      sansSerif = {
        name = "Fira Sans";
        package = pkgs.fira;
      };
      emoji = {
        name = "Noto Color Emoji";
        package = pkgs.noto-fonts-emoji-blob-bin;
      };
    };

    cursor =
      if themePolarity == "light"
      then {
        name = "Catppuccin-Latte-Light-Cursors";
        package = pkgs.catppuccin-cursors.latteLight;
      }
      else {
        name = "Catppuccin-Mocha-Dark-Cursors";
        package = pkgs.catppuccin-cursors.mochaDark;
      };
  };

  # environment.sessionVariables = {
  #   QT_QPA_PLATFORMTHEME = "qt5ct";
  # };
}
