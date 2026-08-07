{pkgs ? import <nixpkgs> {}}: rec {
  # packagename = pkgs.callPackage ./packagename {};
  bookorbit = pkgs.callPackage ./bookorbit {};
  dirstat-rs = pkgs.callPackage ./dirstat-rs {};
  # fabric-ai = pkgs.callPackage ./fabric-ai {};
}
