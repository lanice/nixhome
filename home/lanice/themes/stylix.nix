{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config) fontProfiles;
in {
  imports = [inputs.stylix.homeManagerModules.stylix];

  stylix = {
    enable = true;

    polarity = lib.mkDefault "either";

    image = lib.mkDefault ./background.webp;

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
  };

  # environment.sessionVariables = {
  #   QT_QPA_PLATFORMTHEME = "qt5ct";
  # };
}
