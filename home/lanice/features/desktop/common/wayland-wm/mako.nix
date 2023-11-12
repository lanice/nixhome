{config, ...}: {
  services.mako = {
    enable = true;
    iconPath =
      if config.stylix.polarity == "dark"
      then "${config.gtk.iconTheme.package}/share/icons/Papirus-Dark"
      else "${config.gtk.iconTheme.package}/share/icons/Papirus-Light";
    padding = "10,20";
    anchor = "top-center";
    width = 400;
    height = 150;
    borderSize = 2;
    defaultTimeout = 12000;
    layer = "overlay";
  };
}
