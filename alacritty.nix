{pkgs, ...}: let
  alacritty-wrapped = import ./nixGLWrapper.nix {
    inherit pkgs;
    targetPkg = pkgs.alacritty;
    name = "alacritty";
  };
in {
  programs.alacritty = {
    enable = true;
    package = alacritty-wrapped;
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
        decorations_theme_variant = "dark";
      };
      font = {
        normal = {
          family = "GoMono Nerd Font Mono";
        };
        size = 12;
      };
      colors = {
        primary = {
          background = "#232627";
          foreground = "#fcfcfc";
          dim_foreground = "#eff0f1";
          bright_foreground = "#ffffff";
          dim_background = "#31363b";
          bright_background = "#000000";
        };
        normal = {
          black = "#232627";
          red = "#ed1515";
          green = "#11d116";
          yellow = "#f67400";
          blue = "#1d99f3";
          magenta = "#9b59b6";
          cyan = "#1abc9c";
          white = "#fcfcfc";
        };
        bright = {
          black = "#7f8c8d";
          red = "#c0392b";
          green = "#1cdc9a";
          yellow = "#fdbc4b";
          blue = "#3daee9";
          magenta = "#8e44ad";
          cyan = "#16a085";
          white = "#ffffff";
        };
        dim = {
          black = "#31363b";
          red = "#783228";
          green = "#17a262";
          yellow = "#b65619";
          blue = "#1b668f";
          magenta = "#614a73";
          cyan = "#186c60";
          white = "#63686d";
        };
      };
      theme = "Breeze";
    };
  };
}
