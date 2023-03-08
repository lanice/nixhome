local wezterm = require 'wezterm';
wezterm.add_to_config_reload_watch_list(wezterm.config_dir)

return {
    color_scheme = "Breeze (Gogh)",

    force_reverse_video_cursor = true,

    font = wezterm.font("GoMono Nerd Font Mono"),
    font_size = 12.0,

    initial_cols = 160,
    initial_rows = 48,
    line_height = 1.04,
    window_padding = {
        left = 2,
        right = 2,
        top = 2,
        bottom = 2
    },

    -- hide title bar
    window_decorations = "RESIZE",

    enable_scroll_bar = true,

    -- remember to properly install TERM definitions: https://wezfurlong.org/wezterm/config/lua/config/term.html
    term = 'wezterm',

    keys = {{
        -- Turn off the default ALT-ENTER action
        key = 'Enter',
        mods = 'ALT',
        action = wezterm.action.DisableDefaultAssignment
    }}
}
