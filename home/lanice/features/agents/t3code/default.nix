{
  inputs,
  pkgs,
  ...
}: let
  localPkgs = inputs.self.packages.${pkgs.stdenv.hostPlatform.system};
in {
  home.packages = [localPkgs.t3code];
}
