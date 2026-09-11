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
      jq
      gh
      helix
    ];
  };

  programs.bash.enable = true;
}
