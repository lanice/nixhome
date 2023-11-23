{pkgs ? import <nixpkgs> {}}: rec {
  # packagename = pkgs.callPackage ./packagename {};
  dirstat-rs = pkgs.callPackage ./dirstat-rs {};
}
