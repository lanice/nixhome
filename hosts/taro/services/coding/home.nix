{
  inputs,
  osConfig,
  pkgs,
  ...
}: {
  imports = [
    ../../../../home/lanice/features/agents/codex
    ../../../../home/lanice/features/agents/herdr
    ../../../../home/lanice/features/cli/git-core.nix
  ];

  home = {
    username = osConfig.users.users.coding.name;
    homeDirectory = osConfig.users.users.coding.home;
    stateVersion = "26.05";

    packages = with pkgs; [
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.t3code-server
      nodejs
      pnpm
      bun
      bashInteractive
      coreutils
      findutils
      gnugrep
      gnused
      gawk
      diffutils
      gnutar
      gzip
      zip
      unzip
      curl
      openssh
      procps
      ripgrep
      fd
      dua
      duf
      jq
      gh
      helix
    ];
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      # Fish for SSH logins; keep Bash for agents and remote commands.
      if shopt -q login_shell && [[ -n ''${SSH_TTY:-} && -z ''${BASH_EXECUTION_STRING+x} ]]; then
        exec ${pkgs.fish}/bin/fish --login
      fi
    '';
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting
    '';
    plugins = [
      {
        name = "pure";
        src = pkgs.fishPlugins.pure.src;
      }
    ];
    shellAbbrs = {
      gs = "git status";
      gf = "git fetch";
      gp = "git pull";
      gd = "git diff";
      gco = "git checkout";
      gcan = "git commit --amend --no-edit";
      gbd = "git branch -D";

      p = "pnpm";
    };
  };

  programs.eza.enable = true;
}
