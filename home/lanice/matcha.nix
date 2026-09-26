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

  programs.ghostty.settings = {
    window-decoration = "auto";
    # Super+Return equivalent. Needs Accessibility permission for Ghostty.
    keybind = ["global:opt+enter=new_window"];
  };

  # Global keybind only works while Ghostty runs
  launchd.agents.ghostty = {
    enable = true;
    config = {
      ProgramArguments = ["/usr/bin/open" "-a" "Ghostty"];
      RunAtLoad = true;
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
