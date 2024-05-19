{
  lib,
  pkgs,
  inputs,
  config,
  outputs,
  ...
}: let
  inherit (inputs.nix-colors) colorSchemes;
in {
  imports =
    [
      inputs.nix-index-database.hmModules.nix-index
      inputs.nix-colors.homeManagerModule
      ./mimeapps.nix
      ../features/cli
      ../features/helix
    ]
    ++ (builtins.attrValues outputs.homeManagerModules);

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
      permittedInsecurePackages = [
        # "pkgname"
      ];
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

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  programs = {
    home-manager.enable = true;
    git.enable = true;
  };

  home = {
    username = lib.mkDefault "lanice";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";

    sessionVariables = {
      FLAKE = "$HOME/nixhome";
    };

    # Produce a nice diff of added/removed/changed packages after home-manager switch
    # activation.report-changes = config.lib.dag.entryAnywhere ''
    #   ${pkgs.nvd}/bin/nvd diff $(ls -d1v /nix/var/nix/profiles/per-user/${config.home.username}/profile-*-link | tail -2)
    # '';
  };

  colorscheme = lib.mkOverride 1499 colorSchemes.catppuccin-latte;
  specialisation = {
    dark.configuration.colorscheme = lib.mkOverride 1498 config.colorscheme;
    light.configuration.colorscheme = lib.mkOverride 1498 config.colorscheme;
  };
  home.file = {
    ".colorscheme".text = config.colorscheme.slug;
    ".colorscheme.json".text = builtins.toJSON config.colorscheme;
  };
}
