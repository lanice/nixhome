{lib, ...}: {
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

  home = {
    sessionVariables = {
      EDITOR = "hx";
      TERMINAL = "ghostty";
    };

    stateVersion = lib.mkDefault "26.05";
  };
}
