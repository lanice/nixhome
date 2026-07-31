{pkgs ? import <nixpkgs> {}}: rec {
  # packagename = pkgs.callPackage ./packagename {};
  bookorbit = pkgs.callPackage ./bookorbit {};
  dirstat-rs = pkgs.callPackage ./dirstat-rs {};
  mc-monitor = pkgs.callPackage ./mc-monitor {};
  # fabric-ai = pkgs.callPackage ./fabric-ai {};
}
