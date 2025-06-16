{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: rec {
  gtk = {
    enable = true;
    font = lib.mkDefault {
      name = config.fontProfiles.sansSerif.family;
      size = 12;
    };
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
  };

  services.xsettingsd = {
    enable = lib.mkDefault true;
    settings = {
      # "Net/ThemeName" = "${gtk.theme.name}";
      "Net/IconThemeName" = "${gtk.iconTheme.name}";

      # "Xft/DPI" = 196608;
      # "Gdk/UnscaledDPI" = 98304;
      # # "Gdk/UnscaledDPI" = 196608;
      # # "Gdk/WindowScalingFactor" = 2;
    };
  };
}
