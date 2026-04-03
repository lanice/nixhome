{pkgs ? import <nixpkgs> {}}: rec {
  # packagename = pkgs.callPackage ./packagename {};
  dirstat-rs = pkgs.callPackage ./dirstat-rs {};
  mc-monitor = pkgs.callPackage ./mc-monitor {};
  # fabric-ai = pkgs.callPackage ./fabric-ai {};
}
