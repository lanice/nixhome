{pkgs ? import <nixpkgs> {}}: let
  patchy-cnb = pkgs.callPackage ./patchy-cnb.nix {};
in
  pkgs.callPackage ./claude-desktop.nix {inherit patchy-cnb;}
