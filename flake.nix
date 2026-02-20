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

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    srvos.url = "github:nix-community/srvos";
    srvos.inputs.nixpkgs.follows = "nixpkgs";

    colmena.url = "github:zhaofengli/colmena";
    colmena.inputs.nixpkgs.follows = "nixpkgs";

    zen-browser.url = "github:youwen5/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";

    fabric.url = "github:danielmiessler/fabric";
    fabric.inputs.nixpkgs.follows = "nixpkgs";

    cosmic-manager.url = "github:HeitorAugustoLN/cosmic-manager";
    cosmic-manager.inputs.nixpkgs.follows = "nixpkgs";
    cosmic-manager.inputs.home-manager.follows = "home-manager";

    solaar.url = "github:Svenum/Solaar-Flake/main";
    # solaar.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    colmena,
    ...
  } @ inputs: let
    systems = ["x86_64-linux"];
    forAllSystems = function: nixpkgs.lib.genAttrs systems (system: function nixpkgs.legacyPackages.${system});
  in {
    homeManagerModules = import ./modules/home-manager;

    packages = forAllSystems (pkgs: import ./pkgs {inherit pkgs;});
    devShells = forAllSystems (pkgs: import ./shell.nix {inherit pkgs;});
    formatter = forAllSystems (pkgs: pkgs.alejandra);

    nixosConfigurations = {
      sencha = nixpkgs.lib.nixosSystem {
        modules = [./hosts/sencha];
        specialArgs = {inherit inputs;};
      };
      unstable = nixpkgs.lib.nixosSystem {
        modules = [./hosts/unstable];
        specialArgs = {inherit inputs;};
      };
      boba = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [./hosts/boba];
        specialArgs = {inherit inputs;};
      };
    };

    colmenaHive = colmena.lib.makeHive self.outputs.colmena;
    colmena = {
      meta = {
        nixpkgs = import nixpkgs {
          system = "x86_64-linux";
        };
        specialArgs.inputs = inputs;
      };

      boba = {
        deployment = {
          targetHost = "boba"; # Replace with local network IP if setting up the first time
          targetUser = "lanice";
          buildOnTarget = true;
          tags = ["homelab"];
        };
        imports = [./hosts/boba];
        time.timeZone = "America/New_York";
      };

      unstable = {
        deployment = {
          targetHost = "unstable"; # Replace with local network IP if setting up the first time
          targetUser = "lanice";
          buildOnTarget = true;
          tags = ["homelab"];
        };
        imports = [./hosts/unstable];
        time.timeZone = "America/New_York";
      };
    };
  };
}
