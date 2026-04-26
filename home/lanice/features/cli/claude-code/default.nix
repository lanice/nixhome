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

  home.packages = [
    llm-agents.ccusage
    claude-desktop
  ];

  programs.claude-code = {
    enable = true;
    package = llm-agents.claude-code;

    context = ''
      This is a NixOS system.
    '';

    skills = {
      frontend-design = ./skills/frontend-design;
      ai-sdk = ./skills/ai-sdk;
      convex = ./skills/convex;
      convex-best-practices = ./skills/convex-best-practices;
      convex-functions = ./skills/convex-functions;
      convex-http-actions = ./skills/convex-http-actions;
      convex-schema-validator = ./skills/convex-schema-validator;
      convex-file-storage = ./skills/convex-file-storage;
      freetime = ./skills/freetime;
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
