{pkgs, ...}: let
  wezterm-wrapped = import ../nixGL/nixGLWrapper.nix {
    inherit pkgs;
    targetPkg = pkgs.wezterm.overrideAttrs (old: {
      doCheck = false;
      doInstallCheck = false;
    });
    name = "wezterm";
  };
in {
  imports = [./default.nix];
  programs.wezterm.package = wezterm-wrapped;
}
