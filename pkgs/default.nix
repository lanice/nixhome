{pkgs ? import <nixpkgs> {}}: rec {
  # packagename = pkgs.callPackage ./packagename {};
  bookorbit = pkgs.callPackage ./bookorbit {};
  codexbar-cli = pkgs.callPackage ./codexbar-cli {};
  cosmic-ext-applet-codexbar = pkgs.callPackage ./cosmic-ext-applet-codexbar {};
  dirstat-rs = pkgs.callPackage ./dirstat-rs {};
  # fabric-ai = pkgs.callPackage ./fabric-ai {};
}
