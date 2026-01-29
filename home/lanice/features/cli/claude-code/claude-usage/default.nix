{pkgs, ...}: let
  claude-usage = pkgs.callPackage ./claude-usage.nix {};
in {
  home.packages = [claude-usage];
}
