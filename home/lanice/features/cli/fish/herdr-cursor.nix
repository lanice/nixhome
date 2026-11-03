{
  # Herdr has no cursor setting: match Ghostty's steady bar
  programs.fish.interactiveShellInit = ''
    if set -q HC_TERMINAL_ID
      function __herdr_bar_cursor --on-event fish_prompt
        printf '\e[6 q'
      end
      __herdr_bar_cursor
    end
  '';
}
