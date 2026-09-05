{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ../../../../home/lanice/features/agents/codex
    ../../../../home/lanice/features/cli/git-core.nix
  ];

  home = {
    username = "t3code";
    homeDirectory = "/home/t3code";
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
    ];
  };

  programs.bash.enable = true;
}
