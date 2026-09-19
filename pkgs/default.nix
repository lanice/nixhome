{pkgs ? import <nixpkgs> {}}: rec {
  # packagename = pkgs.callPackage ./packagename {};
  codexbar-cli = pkgs.callPackage ./codexbar-cli {};
  cosmic-ext-applet-codexbar = pkgs.callPackage ./cosmic-ext-applet-codexbar {};
  t3code = pkgs.callPackage ./t3code {};
  t3code-server = pkgs.callPackage ./t3code/server.nix {};
}
