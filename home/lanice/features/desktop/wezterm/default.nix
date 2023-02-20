{pkgs, ...}: {
  programs.wezterm = {
    enable = true;

    colorSchemes = {
      "Breeze Custom" = {
        ansi = [
          "#232627" # black
          "#ed1515" # red
          "#11d116" # green
          "#f67400" # yellow
          "#1d99f3" # blue
          "#9b59b6" # magenta
          "#1abc9c" # cyan
          "#fcfcfc" # white
        ];
        brights = [
          "#7f8c8d" # bright-black
          "#c0392b" # bright-red
          "#1cdc9a" # bright-green
          "#fdbc4b" # bright-yellow
          "#3daee9" # bright-blue
          "#8e44ad" # bright-magenta
          "#16a085" # bright-cyan
          "#ffffff" # bright-white
        ];
        foreground = "#fcfcfc";
        background = "#232627";

        cursor_fg = "#232627";
        cursor_bg = "#fcfcfc";
        cursor_border = "#fcfcfc";

        selection_fg = "#232627";
        selection_bg = "#fcfcfc";

        scrollbar_thumb = "#fcfcfc";
      };
    };

    extraConfig =
      /*
      lua
      */
      ''
        return {
          font = wezterm.font("GoMono Nerd Font Mono"),
          font_size = 12.0,
          color_scheme = "Breeze Custom",
          hide_tab_bar_if_only_one_tab = true,

          set_environment_variables = {
            TERMINFO_DIRS = '/home/lanice/.nix-profile/share/terminfo',
            WSLENV = 'TERMINFO_DIRS',
          },
          term = 'wezterm',

          enable_scroll_bar = true,
          initial_cols = 160,
          initial_rows = 48,
          line_height = 1.04,
          window_padding = {
            left = 2,
            right = 2,
            top = 2,
            bottom = 2,
          },

          keys = {
            -- Turn off the default ALT-ENTER Hide action
            {
              key = 'Enter',
              mods = 'ALT',
              action = wezterm.action.DisableDefaultAssignment,
            },
          },
        }
      '';
  };
}
