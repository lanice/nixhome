{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: let
  themePath = "/" + config.theme;

  scheme = themePath + "/" + config.theme + ".yaml";
  themePolarity = lib.removeSuffix "\n" (builtins.readFile (./. + themePath + "/polarity.txt"));

  backgroundUrl = builtins.readFile (./. + themePath + "/backgroundurl.txt");
  backgroundSha256 = builtins.readFile (./. + themePath + "/backgroundsha256.txt");

  inherit (config) fontProfiles;
in {
  imports = [inputs.stylix.homeManagerModules.stylix];

  stylix = {
    base16Scheme = ./. + scheme;
    polarity = themePolarity;

    image = pkgs.fetchurl {
      url = backgroundUrl;
      sha256 = backgroundSha256;
    };

    # image = ./background.webp;

    fonts = {
      monospace = {
        name = fontProfiles.monospace.family;
        package = fontProfiles.monospace.package;
      };
      serif = {
        name = fontProfiles.serif.family;
        package = fontProfiles.serif.package;
      };
      sansSerif = {
        name = fontProfiles.sansSerif.family;
        package = fontProfiles.sansSerif.package;
      };
      emoji = {
        name = fontProfiles.emoji.family;
        package = fontProfiles.emoji.package;
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
