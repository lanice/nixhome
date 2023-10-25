{config, ...}: let
  inherit (config.colorscheme) colors;
in {
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
        normal = {
          family = config.fontProfiles.monospace.family;
        };
        size = 12;
      };
      colors = {
        primary = {
          background = "#${colors.base00}";
          foreground = "#${colors.base05}";
        };
        cursor = {
          text = "#${colors.base00}";
          cursor = "#${colors.base05}";
        };
        normal = {
          black = "#${colors.base08}";
          red = "#${colors.base09}";
          green = "#${colors.base0A}";
          yellow = "#${colors.base0B}";
          blue = "#${colors.base0C}";
          magenta = "#${colors.base0D}";
          cyan = "#${colors.base0E}";
          white = "#${colors.base0F}";
        };
        bright = {
          black = "#${colors.base00}";
          red = "#${colors.base01}";
          green = "#${colors.base02}";
          yellow = "#${colors.base03}";
          blue = "#${colors.base04}";
          magenta = "#${colors.base05}";
          cyan = "#${colors.base06}";
          white = "#${colors.base07}";
        };
      };
      theme = config.colorscheme.slug;
    };
  };
}
