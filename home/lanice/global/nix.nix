{
  lib,
  pkgs,
  inputs,
  ...
}: {
  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = ["nix-command" "flakes"];
      warn-dirty = false;
      # Only for privileged users. Set in the nixos system config anyway
      # auto-optimise-store = lib.mkDefault true;
    };

    # Pin nixpkgs# to the flake's nixpkgs (see hosts/common/global/nix.nix)
    registry.nixpkgs.flake = inputs.nixpkgs;
  };
}
