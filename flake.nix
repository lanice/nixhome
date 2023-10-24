{
  # starter config from: https://git.sr.ht/~misterio/nix-config

  description = "My nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # nixGL
    nixgl.url = "github:guibou/nixGL";
    nixgl.inputs.nixpkgs.follows = "nixpkgs";

    hardware.url = "github:nixos/nixos-hardware";

    vscode-server.url = "github:msteen/nixos-vscode-server";
    vscode-server.inputs.nixpkgs.follows = "nixpkgs";

    minecraft-servers.url = "github:mkaito/nixos-modded-minecraft-servers";
    minecraft-servers.inputs.nixpkgs.follows = "nixpkgs";

    # Shameless plug: looking for a way to nixify your themes and make
    # everything match nicely? Try nix-colors!
    # nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixgl,
    ...
  } @ inputs: let
    inherit (self) outputs;
    forAllSystems = nixpkgs.lib.genAttrs [
      # "aarch64-linux"
      # "i686-linux"
      "x86_64-linux"
      # "aarch64-darwin"
      # "x86_64-darwin"
    ];

    nixGlOverlay = {config, ...}: {nixpkgs.overlays = [nixgl.overlay];};
  in rec {
    # Devshell for bootstrapping
    # Acessible through 'nix develop' or 'nix-shell' (legacy)
    devShells = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in
        import ./shell.nix {inherit pkgs;}
    );

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      tofu = nixpkgs.lib.nixosSystem {
        modules = [./hosts/tofu];
        specialArgs = {inherit inputs outputs;};
      };
      sencha = nixpkgs.lib.nixosSystem {
        modules = [./hosts/sencha];
        specialArgs = {inherit inputs outputs;};
      };
      unstable = nixpkgs.lib.nixosSystem {
        modules = [./hosts/unstable inputs.vscode-server.nixosModule];
        specialArgs = {inherit inputs outputs;};
      };
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = {
      "lanice@tofu" = home-manager.lib.homeManagerConfiguration {
        modules = [./home/lanice/tofu.nix nixGlOverlay];
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit inputs outputs;};
      };
      "lanice@sencha" = home-manager.lib.homeManagerConfiguration {
        modules = [./home/lanice/sencha.nix nixGlOverlay];
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit inputs outputs;};
      };
      "lanice@GreenGen5" = home-manager.lib.homeManagerConfiguration {
        modules = [./home/lanice/greengen5.nix nixGlOverlay];
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit inputs outputs;};
      };
      "lanice@unstable" = home-manager.lib.homeManagerConfiguration {
        modules = [./home/lanice/unstable.nix];
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit inputs outputs;};
      };
    };
  };
}
