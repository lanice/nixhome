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
          dim_foreground = "#${colors.base05}";
          bright_foreground = "#${colors.base05}";
        };
        cursor = {
          text = "#${colors.base00}";
          cursor = "#${colors.base06}";
        };
        vi_mode_cursor = {
          text = "#${colors.base00}";
          cursor = "#${colors.base07}";
        };
        search = {
          matches = {
            foreground = "#${colors.base00}";
            background = "#${colors.base05}";
          };
          focused_match = {
            foreground = "#${colors.base00}";
            background = "#${colors.base0B}";
          };
          footer_bar = {
            foreground = "#${colors.base00}";
            background = "#${colors.base05}";
          };
        };
        hints = {
          start = {
            foreground = "#${colors.base00}";
            background = "#${colors.base0A}";
          };
          end = {
            foreground = "#${colors.base00}";
            background = "#${colors.base04}";
          };
        };
        selection = {
          text = "#${colors.base00}";
          background = "#${colors.base06}";
        };
        normal = {
          black = "#${colors.base05}";
          red = "#${colors.base08}";
          green = "#${colors.base0B}";
          yellow = "#${colors.base0A}";
          blue = "#${colors.base0D}";
          magenta = "#${colors.base0F}";
          cyan = "#${colors.base0C}";
          white = "#${colors.base04}";
        };
        bright = {
          black = "#${colors.base04}";
          red = "#${colors.base08}";
          green = "#${colors.base0B}";
          yellow = "#${colors.base0A}";
          blue = "#${colors.base0D}";
          magenta = "#${colors.base0F}";
          cyan = "#${colors.base0C}";
          white = "#${colors.base02}";
        };
        dim = {
          black = "#${colors.base05}";
          red = "#${colors.base08}";
          green = "#${colors.base0B}";
          yellow = "#${colors.base0A}";
          blue = "#${colors.base0D}";
          magenta = "#${colors.base0F}";
          cyan = "#${colors.base0C}";
          white = "#${colors.base04}";
        };
      };
      theme = config.colorscheme.slug;
    };
  };
}
