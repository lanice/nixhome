{
  programs.wezterm = {
    enable = true;
    extraConfig =
      /*
      lua
      */
      ''
        return {
          font_size = 12.0,
          hide_tab_bar_if_only_one_tab = true,
          window_close_confirmation = "NeverPrompt",
          set_environment_variables = {
            TERM = 'wezterm',
          },
          initial_cols = 160,
          initial_rows = 48,
          window_padding = {
              left = 2,
              right = 2,
              top = 2,
              bottom = 2
          },
          window_decorations = "RESIZE",
          term = 'wezterm',
        }
      '';
  };
}
