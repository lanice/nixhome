{pkgs}:
import ./nixGLWrapper.nix {
  inherit pkgs;
  targetPkg = pkgs.whatsapp-for-linux;
  name = "whatsapp-for-linux";
}
