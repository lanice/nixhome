{
  lib,
  pkgs,
  inputs,
  config,
  outputs,
  ...
}: {
  imports = [
    ../features/cli
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = ["nix-command" "flakes" "repl-flake"];
      warn-dirty = false;
      auto-optimise-store = lib.mkDefault true;
    };

    # Add each flake input as a registry
    # To make nix3 commands consistent with the flake
    registry = lib.mapAttrs (_: value: {flake = value;}) inputs;
  };

  programs = {
    home-manager.enable = true;
    git.enable = true;
  };

  home = {
    username = lib.mkDefault "lanice";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";

    # Produce a nice diff of added/removed/changed packages after home-manager switch
    # activation.report-changes = config.lib.dag.entryAnywhere ''
    #   ${pkgs.nvd}/bin/nvd diff $(ls -d1v /nix/var/nix/profiles/per-user/${config.home.username}/profile-*-link | tail -2)
    # '';

    sessionVariables.NIX_PATH = "nixpkgs=${config.xdg.configHome}/nix/inputs/nixpkgs$\{NIX_PATH:+:$NIX_PATH}";
  };

  xdg.configFile."nix/inputs/nixpkgs".source = inputs.nixpkgs.outPath;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
