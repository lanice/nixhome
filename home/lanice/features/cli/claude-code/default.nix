{
  pkgs,
  inputs,
  ...
}: let
  llm-agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  claude-desktop = inputs.claude-desktop.packages.${pkgs.stdenv.hostPlatform.system}.default;
in {
  imports = [
    # ./ralph-wiggum
    ./claude-usage
  ];

  programs.fish.shellAbbrs = {
    cld = "claude";
  };

  home.packages = [
    llm-agents.ccusage
    claude-desktop
  ];

  programs.claude-code = {
    enable = true;
    package = llm-agents.claude-code;

    context = ''
      This is a NixOS system.

      ## Shell

      The `Bash` tool executes commands under **zsh** (`$SHELL`) — not the
      interactive **fish** shown in the environment header, which is only the
      shell `claude` was launched from. Write tool commands in POSIX/bash;
      never fish syntax (`for … end`, `; and`, `; or`, `(cmd)` substitution).

      Commands you hand the user to run themselves land in their interactive **fish**,
      so write those in fish syntax.
    '';

    skills = {
      frontend-design = ./skills/frontend-design;
      unslop = ./skills/unslop;
      # freetime = ./skills/freetime;
    };

    settings = {
      alwaysThinkingEnabled = true;
      includeCoAuthoredBy = false;
      cleanupPeriodDays = 700;

      autoMemoryEnabled = false;
      tui = "fullscreen";

      model = "fable";

      attribution = {
        commit = "";
        pr = "";
        sessionUrl = false;
      };

      permissions = {
        defaultMode = "auto";
      };

      statusLine = {
        type = "command";
        # command = "input=$(cat); echo \"[$(echo \"$input\" | ${pkgs.jq}/bin/jq -r '.model.display_name')] 📁 $(basename \"$(echo \"$input\" | ${pkgs.jq}/bin/jq -r '.workspace.current_dir')\")\"";
        command = "bunx ccstatusline@latest";
        padding = 0;
      };
    };
  };
}
