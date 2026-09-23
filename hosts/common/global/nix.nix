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
      # Off-tailnet, cache.lanice.dev is unreachable; fail fast instead of curl's default.
      connect-timeout = 5;
      # cache.lanice.dev: boba's store (hosts/boba/services/binary-cache.nix), tailnet-only.
      extra-substituters = ["https://devenv.cachix.org/" "https://cache.numtide.com" "https://cache.nixos-cuda.org" "https://colmena.cachix.org" "https://cache.lanice.dev"];
      extra-trusted-public-keys = ["devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=" "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M=" "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg=" "cache.lanice.dev-1:Orpw7cmBqU7sWdpfQstHWq71ofRpi0ltLGjZSvFu7Eo="];
    };
    # GC handled by programs.nh.clean (see ./nh.nix)

    # Add each flake input as a registry
    # To make nix3 commands consistent with the flake
    registry = lib.mapAttrs (_: value: {flake = value;}) inputs;

    # Add nixpkgs input to NIX_PATH
    # This lets nix2 commands still use <nixpkgs>
    nixPath = ["nixpkgs=${inputs.nixpkgs.outPath}"];
  };
}
