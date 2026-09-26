{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  herdr = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.herdr;
in {
  imports = [
    ./global # includes features/cli,features/helix

    # not ./features/agents: t3code is x86_64-linux only
    ./features/agents/common
    ./features/agents/claude-code
    ./features/agents/codex
    ./features/agents/omp
    ./features/agents/herdr

    ./features/cli/ssh.nix

    ./features/desktop/common/font.nix
    ./features/desktop/ghostty

    ./themes/catppuccin-mocha
  ];

  programs.ghostty.settings.window-decoration = "auto";

  # Owns the default herdr session, like taro's herdr.service; clients attach over SSH.
  launchd.agents.herdr = {
    enable = true;
    config = {
      ProgramArguments = ["${herdr}/bin/herdr" "server"];
      EnvironmentVariables = {
        XDG_CONFIG_HOME = config.xdg.configHome; # socket: ~/.config/herdr/herdr.sock
        SHELL = "/run/current-system/sw/bin/fish"; # pane shell; launchd env has none
      };
      RunAtLoad = true;
      KeepAlive = true;
    };
  };

  home = {
    sessionVariables = {
      EDITOR = "hx";
      TERMINAL = "ghostty";
    };

    stateVersion = lib.mkDefault "26.05";
  };
}
