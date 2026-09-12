{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  herdr = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.herdr;
  integrations = "${herdr}/share/herdr/integrations";
  codexDir =
    if config.home.preferXdgDirectories
    then "${config.xdg.configHome}/codex"
    else "${config.home.homeDirectory}/.codex";
  codexHook = "${codexDir}/herdr-agent-state.sh";
  claudeHook = "${config.programs.claude-code.configDir}/hooks/herdr-agent-state.sh";
  sessionHook = path: {
    type = "command";
    command = "bash '${lib.replaceStrings ["'"] ["'\"'\"'"] path}' session";
    timeout = 10;
  };
in {
  home.packages =
    [herdr]
    ++ lib.optionals (config.programs.codex.enable || config.programs.claude-code.enable) [pkgs.python3];

  home.file = lib.mkMerge [
    (lib.mkIf config.programs.codex.enable {
      "${codexHook}" = {
        source = "${integrations}/codex/herdr-agent-state.sh";
        executable = true;
      };
    })
    (lib.mkIf config.programs.claude-code.enable {
      "${claudeHook}" = {
        source = "${integrations}/claude/herdr-agent-state.sh";
        executable = true;
      };
    })
    (lib.mkIf (config.programs.omp.enable or false) {
      ".omp/agent/extensions/herdr-omp-agent-state.ts".source = "${integrations}/omp/herdr-agent-state.ts";
    })
  ];

  programs.codex = lib.mkIf config.programs.codex.enable {
    hooks.SessionStart = [
      {
        hooks = [(sessionHook codexHook)];
      }
    ];
  };

  programs.claude-code.settings.hooks = lib.mkIf config.programs.claude-code.enable {
    SessionStart = [
      {
        matcher = "*";
        hooks = [(sessionHook claudeHook)];
      }
    ];
  };
}
