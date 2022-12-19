{pkgs}:
import ./nixGLWrapper.nix {
  inherit pkgs;
  targetPkg = pkgs.tdesktop;
  name = "telegram-desktop";
}
