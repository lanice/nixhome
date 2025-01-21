{
  inputs,
  lib,
  ...
}: {
  nix = {
    settings = {
      auto-optimise-store = lib.mkDefault true;
      experimental-features = ["nix-command" "flakes"];
      warn-dirty = false;
      flake-registry = ""; # Disable global flake registry

      trusted-substituters = ["https://devenv.cachix.org/"];
      extra-substituters = ["https://devenv.cachix.org/"];
      extra-trusted-public-keys = ["devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };

    # Add each flake input as a registry
    # To make nix3 commands consistent with the flake
    registry = lib.mapAttrs (_: value: {flake = value;}) inputs;

    # Add nixpkgs input to NIX_PATH
    # This lets nix2 commands still use <nixpkgs>
    nixPath = ["nixpkgs=${inputs.nixpkgs.outPath}"];
  };
}
