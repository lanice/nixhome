{pkgs, ...}: {
  imports = [
    ./claude-code
    ./omp
  ];

  home.packages = [pkgs.codex];
}
