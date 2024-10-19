{
  lib,
  pkgs,
  inputs,
  config,
  ...
}: {
  imports =
    [
      inputs.nix-index-database.hmModules.nix-index
      ./mimeapps.nix
      ../features/cli
      ../features/helix
    ]
    ++ (builtins.attrValues inputs.self.homeManagerModules);

  nixpkgs = {
    overlays = builtins.attrValues inputs.self.overlays;
    config = {
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
      permittedInsecurePackages = [
        # "pkgname"
        "olm-3.2.16" # https://github.com/NixOS/nixpkgs/pull/338006
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

  home.file = {
    ".colorscheme".text = config.theme;
    # ".colorscheme.json".text = builtins.toJSON config.stylix.colorscheme;
  };
}
