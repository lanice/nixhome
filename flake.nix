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

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    hyprland.url = "github:hyprwm/hyprland";
    hyprland.inputs.nixpkgs.follows = "nixpkgs";

    hyprwm-contrib.url = "github:hyprwm/contrib";
    hyprwm-contrib.inputs.nixpkgs.follows = "nixpkgs";

    firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    firefox-addons.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:danth/stylix";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixgl,
    ...
  } @ inputs: let
    inherit (self) outputs;
    lib = nixpkgs.lib // home-manager.lib;
    systems = ["x86_64-linux"];
    forEachSystem = f: lib.genAttrs systems (system: f pkgsFor.${system});
    pkgsFor = lib.genAttrs systems (system:
      import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      });
    nixGlOverlay = {config, ...}: {nixpkgs.overlays = [nixgl.overlay];};
  in {
    inherit lib;
    homeManagerModules = import ./modules/home-manager;
    nixosModules = import ./modules/nixos;

    overlays = import ./overlays {inherit inputs;};

    packages = forEachSystem (pkgs: import ./pkgs {inherit pkgs;});
    devShells = forEachSystem (pkgs: import ./shell.nix {inherit pkgs;});
    formatter = forEachSystem (pkgs: pkgs.nixpkgs-fmt);

    wallpapers = import ./home/lanice/wallpapers;

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      sencha = lib.nixosSystem {
        modules = [./hosts/sencha];
        specialArgs = {inherit inputs outputs;};
      };
      tofu = lib.nixosSystem {
        modules = [./hosts/tofu];
        specialArgs = {inherit inputs outputs;};
      };
      unstable = lib.nixosSystem {
        modules = [./hosts/unstable inputs.vscode-server.nixosModule];
        specialArgs = {inherit inputs outputs;};
      };
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = {
      "lanice@sencha" = lib.homeManagerConfiguration {
        modules = [./home/lanice/sencha.nix];
        pkgs = pkgsFor.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
      };
      "lanice@tofu" = lib.homeManagerConfiguration {
        modules = [./home/lanice/tofu.nix];
        pkgs = pkgsFor.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
      };
      "lanice@unstable" = lib.homeManagerConfiguration {
        modules = [./home/lanice/unstable.nix];
        pkgs = pkgsFor.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
      };
      "lanice@GreenGen5" = lib.homeManagerConfiguration {
        modules = [./home/lanice/greengen5.nix nixGlOverlay];
        pkgs = pkgsFor.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
      };
    };
  };
}
