{
  description = "My nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    vscode-server.url = "github:msteen/nixos-vscode-server";
    vscode-server.inputs.nixpkgs.follows = "nixpkgs";

    minecraft-servers.url = "github:mkaito/nixos-modded-minecraft-servers";
    minecraft-servers.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    firefox-addons.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.home-manager.follows = "home-manager";

    hardware.url = "github:nixos/nixos-hardware";
    stylix.url = "github:danth/stylix";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    systems = ["x86_64-linux"];
    forAllSystems = function: nixpkgs.lib.genAttrs systems (system: function nixpkgs.legacyPackages.${system});
  in {
    homeManagerModules = import ./modules/home-manager;

    packages = forAllSystems (pkgs: import ./pkgs {inherit pkgs;});
    devShells = forAllSystems (pkgs: import ./shell.nix {inherit pkgs;});

    nixosConfigurations = {
      sencha = nixpkgs.lib.nixosSystem {
        modules = [./hosts/sencha];
        specialArgs = {inherit inputs;};
      };
      unstable = nixpkgs.lib.nixosSystem {
        modules = [./hosts/unstable];
        specialArgs = {inherit inputs;};
      };
    };
  };
}
