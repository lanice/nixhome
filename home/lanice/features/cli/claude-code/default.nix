{
  pkgs,
  inputs,
  ...
}: let
  llm-agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in {
  imports = [
    ./ralph-wiggum
    ./claude-usage
  ];

  home.packages = [
    llm-agents.ccusage
  ];

  programs.claude-code = {
    enable = true;
    package = llm-agents.claude-code;

    memory.text = ''
      ## General
      - In all interactions and commit messages, be extremely concise and sacrifice grammar for the sake of concision.

      ## Plans
      - At the end of each plan, give me a list of unresolved questions to answer, if any. Make the questions extremely concise. Sacrifice grammar for the sake of concision.
    '';

    skills = {
      frontend-design = ./skills/frontend-design;
      ai-sdk = ./skills/ai-sdk;
      convex = ./skills/convex;
      convex-best-practices = ./skills/convex-best-practices;
      convex-functions = ./skills/convex-functions;
      convex-http-actions = ./skills/convex-http-actions;
      convex-schema-validator = ./skills/convex-schema-validator;
    };

    settings = {
      alwaysThinkingEnabled = true;
      includeCoAuthoredBy = false;
      cleanupPeriodDays = 700;

      statusLine = {
        type = "command";
        # command = "input=$(cat); echo \"[$(echo \"$input\" | ${pkgs.jq}/bin/jq -r '.model.display_name')] 📁 $(basename \"$(echo \"$input\" | ${pkgs.jq}/bin/jq -r '.workspace.current_dir')\")\"";
        command = "bunx ccstatusline@latest";
        padding = 0;
      };
    };
  };
}
