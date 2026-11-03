{
  lib,
  pkgs,
  ...
}: let
  jq = lib.getExe pkgs.jq;

  # hc doesn't resume agents after a reboot (herdr-core#13): note the session on its terminal.
  noteSession = pkgs.writeShellApplication {
    name = "hc-note-claude-session";
    runtimeInputs = [pkgs.procps];
    text = ''
      [ -n "''${HC_TERMINAL_ID:-}" ] || exit 0
      input=$(cat)
      [ -z "$(${jq} -r '.agent_id // empty' <<<"$input")" ] || exit 0

      # Foreground claude only: agent tool calls run without the terminal.
      pid=$PPID
      until [[ "$(ps -o comm= -p "$pid")" == *claude* ]]; do
        pid=$(ps -o ppid= -p "$pid" | tr -d ' ')
        [ "''${pid:-0}" -gt 1 ] || exit 0
      done
      read -r pgid tpgid < <(ps -o pgid=,tpgid= -p "$pid")
      [ "$pgid" = "$tpgid" ] || exit 0

      id=$(${jq} -r '.session_id // empty' <<<"$input")
      [ -n "$id" ] || exit 0
      cwd=''${CLAUDE_PROJECT_DIR:-$(${jq} -r '.cwd // empty' <<<"$input")}
      hc label "$HC_TERMINAL_ID" "claude.resume=$id" "claude.resume.cwd=$cwd" >/dev/null 2>&1 || true
    '';
  };
in {
  programs.claude-code.settings.hooks.SessionStart = [
    {
      matcher = "*";
      hooks = [
        {
          type = "command";
          command = lib.getExe noteSession;
          timeout = 10;
        }
      ];
    }
  ];

  programs.fish.interactiveShellInit = ''
    if set -q HC_TERMINAL_ID
      # Quit on purpose: forget the session. Killed or shutting down: keep it.
      function claude --wraps claude
        command claude $argv
        set -l code $status
        if test $code -lt 128; and test (systemctl is-system-running) != stopping
          hc label $HC_TERMINAL_ID claude.resume= claude.resume.cwd= >/dev/null 2>&1
        end
        return $code
      end

      # hc's own shell (direct child of its holder), not `fish` typed inside one.
      if test "$(cat /proc/(ps -o ppid= -p $fish_pid | string trim)/comm)" = herdr-core
        function __hc_resume_claude --on-event fish_prompt
          functions -e __hc_resume_claude
          set -l note (hc get $HC_TERMINAL_ID --json 2>/dev/null | ${jq} -r '.labels | .["claude.resume"] // empty, .["claude.resume.cwd"] // empty')
          set -q note[1]; or return
          hc label $HC_TERMINAL_ID claude.resume= claude.resume.cwd= >/dev/null 2>&1
          # At the prompt, not in this handler: it needs fish's job control.
          cd $note[2]; or return
          commandline -r "claude --resume $note[1]"
          commandline -f execute
        end
      end
    end
  '';
}
