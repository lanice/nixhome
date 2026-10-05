{
  config,
  lib,
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

  # Read-only: edit ccstatusline.json, not via the ccstatusline TUI
  xdg.configFile."ccstatusline/settings.json" = {
    source = ./ccstatusline.json;
    force = true;
  };

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

      # settings.json is read-only, so `/plugin enable` can't persist
      enabledPlugins = {
        "cc-plugin-you-should-know@builtin" = true;
      };

      statusLine = {
        type = "command";
        # command = "input=$(cat); echo \"[$(echo \"$input\" | ${pkgs.jq}/bin/jq -r '.model.display_name')] 📁 $(basename \"$(echo \"$input\" | ${pkgs.jq}/bin/jq -r '.workspace.current_dir')\")\"";
        command = lib.getExe llm-agents.ccstatusline;
        padding = 0;
      };
    };
  };
}
