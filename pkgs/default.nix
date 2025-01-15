{pkgs ? import <nixpkgs> {}}: rec {
  # packagename = pkgs.callPackage ./packagename {};
  dirstat-rs = pkgs.callPackage ./dirstat-rs {};
  # fabric-ai = pkgs.callPackage ./fabric-ai {};

  # Need to fix my setup for unfree licenses in flake inputs, then use this instead:
  # https://github.com/k3d3/claude-desktop-linux-flake
  # claude-desktop = pkgs.callPackage ./claude-desktop {};
}
