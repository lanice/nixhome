{pkgs, ...}: let
  alacritty-wrapped = import ../nixGL/nixGLWrapper.nix {
    inherit pkgs;
    targetPkg = pkgs.alacritty;
    name = "alacritty";
  };
in {
  imports = [./default.nix];
  programs.alacritty.package = alacritty-wrapped;
}
