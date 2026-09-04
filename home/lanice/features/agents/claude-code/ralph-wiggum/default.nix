{pkgs, ...}: {
  home.packages = [pkgs.jq];

  home.file.".claude/scripts/setup-ralph-loop.sh" = {
    source = ./scripts/setup-ralph-loop.sh;
    executable = true;
  };

  home.file.".claude/hooks/ralph-stop-hook.sh" = {
    source = ./hooks/stop-hook.sh;
    executable = true;
  };

  programs.claude-code = {
    commands.ralph-help = ./commands/ralph-help.md;
    commands.ralph-loop = ./commands/ralph-loop.md;
    commands.ralph-cancel-loop = ./commands/ralph-cancel.md;

    settings.hooks.Stop = [
      {
        hooks = [
          {
            type = "command";
            command = "$HOME/.claude/hooks/ralph-stop-hook.sh";
          }
        ];
      }
    ];
  };
}
