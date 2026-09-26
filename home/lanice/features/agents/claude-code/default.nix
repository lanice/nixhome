{
  config,
  pkgs,
  inputs,
  ...
}: let
  llm-agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in {
  imports = [
    ./claude-usage
  ];

  programs.fish.shellAbbrs = {
    cld = "claude";
  };

  home.packages = [
    llm-agents.ccusage
  ];

  programs.claude-code = {
    enable = true;
    package = llm-agents.claude-code;

    inherit (config.agents) context;

    settings = {
      alwaysThinkingEnabled = true;
      includeCoAuthoredBy = false;
      cleanupPeriodDays = 700;

      autoMemoryEnabled = false;
      tui = "fullscreen";
      theme = "auto";

      # model = "opus";

      modelSettings = {
        "claude-opus-5-5" = {
          effortLevel = "high";
        };
      };

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
