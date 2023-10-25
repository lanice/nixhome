{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  inherit (inputs.nix-colors.lib-contrib {inherit pkgs;}) gtkThemeFromScheme;
in rec {
  gtk = {
    enable = true;
    font = {
      name = config.fontProfiles.regular.family;
      size = 12;
    };
    theme = {
      name = "${config.colorscheme.slug}";
      package = gtkThemeFromScheme {scheme = config.colorscheme;};
    };
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
  };

  services.xsettingsd = {
    enable = lib.mkDefault true;
    settings = {
      "Net/ThemeName" = "${gtk.theme.name}";
      "Net/IconThemeName" = "${gtk.iconTheme.name}";

      # "Xft/DPI" = 196608;
      # "Gdk/UnscaledDPI" = 98304;
      # # "Gdk/UnscaledDPI" = 196608;
      # # "Gdk/WindowScalingFactor" = 2;
    };
  };
}
