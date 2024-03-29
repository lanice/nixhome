{
  lib,
  pkgs,
  config,
  ...
}: rec {
  gtk = {
    enable = true;
    # Set via stylix now, but keeping this as default
    font = lib.mkDefault {
      name = config.stylix.fonts.sansSerif.name;
      size = 12;
    };
    # theme = {
    #   name = "${config.colorscheme.slug}";
    #   package = gtkThemeFromScheme {scheme = config.colorscheme;};
    # };
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
