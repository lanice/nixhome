{config, ...}: {
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        dimensions = {
          columns = 160;
          lines = 48;
        };
        padding = {
          x = 2;
          y = 2;
        };
        dynamic_padding = true;
        decorations_theme_variant = "Dark";
      };
      font = {
        size = 12;
      };
    };
  };
}
