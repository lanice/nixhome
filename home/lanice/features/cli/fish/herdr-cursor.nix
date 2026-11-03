{
  # Herdr has no cursor setting: match Ghostty's steady bar
  # WINCH: reopening the window resets the shape and resizes every terminal.
  programs.fish.interactiveShellInit = ''
    if set -q HC_TERMINAL_ID
      function __herdr_bar_cursor --on-event fish_prompt --on-signal WINCH
        printf '\e[6 q'
      end
      __herdr_bar_cursor
    end
  '';
}
