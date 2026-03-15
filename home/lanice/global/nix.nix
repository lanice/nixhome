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

    # Add each flake input as a registry
    # To make nix3 commands consistent with the flake
    registry = lib.mapAttrs (_: value: {flake = value;}) inputs;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
