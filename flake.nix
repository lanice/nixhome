{
  description = "My nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

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
    hardware.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    srvos.url = "github:nix-community/srvos";
    srvos.inputs.nixpkgs.follows = "nixpkgs";

    # not following nixpkgs so colmena.cachix.org hits (else Rust rebuild every bump)
    colmena.url = "github:zhaofengli/colmena";

    nixgl.url = "github:nix-community/nixGL";
    nixgl.inputs.nixpkgs.follows = "nixpkgs";

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
    zen-browser.inputs.home-manager.follows = "home-manager";

    claude-desktop.url = "github:aaddrick/claude-desktop-debian";
    claude-desktop.inputs.nixpkgs.follows = "nixpkgs";

    llm-agents.url = "github:numtide/llm-agents.nix";
    catppuccin.url = "github:catppuccin/nix";
    catppuccin.inputs.nixpkgs.follows = "nixpkgs";

    cosmic-manager.url = "github:HeitorAugustoLN/cosmic-manager";
    cosmic-manager.inputs.nixpkgs.follows = "nixpkgs";
    cosmic-manager.inputs.home-manager.follows = "home-manager";

    cosmic-applets-collection.url = "github:wingej0/ext-cosmic-applets-flake";
    cosmic-applets-collection.inputs.nixpkgs.follows = "nixpkgs";

    dbosctl.url = "github:dbos-inc/dbos-ctl/v0.10.1";
    dbosctl.inputs.nixpkgs.follows = "nixpkgs";

    kenku-fm.url = "github:lanice/kenku-fm.nix";

    # Identifying data (email addresses, mail-archive source accounts) that
    # must not live in this public repo. Dumb data, not a flake. Every host's
    # eval forces it; fetches hit the by-rev cache and work offline, but a
    # fresh machine needs the GitHub SSH key before its first build.
    nixhome-private = {
      url = "git+ssh://git@github.com/lanice/nixhome-private";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    colmena,
    ...
  } @ inputs: let
    systems = ["x86_64-linux" "aarch64-linux"];
    forAllSystems = function: nixpkgs.lib.genAttrs systems (system: function nixpkgs.legacyPackages.${system});
  in {
    homeManagerModules = import ./modules/home-manager;

    packages = forAllSystems (pkgs: import ./pkgs {inherit pkgs;});
    devShells = forAllSystems (pkgs: import ./shell.nix {inherit pkgs;});
    formatter = forAllSystems (pkgs: pkgs.alejandra);

    checks = forAllSystems (pkgs: let
      system = pkgs.stdenv.hostPlatform.system;
      mkLintCheck = name: package: command:
        pkgs.runCommand name {nativeBuildInputs = [package];} ''
          ${command} ${self}
          touch $out
        '';
    in {
      formatting = mkLintCheck "alejandra-check" pkgs.alejandra "alejandra --check";
      statix = mkLintCheck "statix-check" pkgs.statix "statix check --config ${self}";
      deadnix = mkLintCheck "deadnix-check" pkgs.deadnix "deadnix --fail";

      packages = pkgs.linkFarm "package-checks" (
        pkgs.lib.mapAttrsToList (name: path: {inherit name path;}) self.packages.${system}
      );
    });

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
      taro = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [./hosts/taro];
        specialArgs = {inherit inputs;};
      };
      longjing = nixpkgs.lib.nixosSystem {
        modules = [./hosts/longjing];
        specialArgs = {inherit inputs;};
      };
    };

    homeConfigurations."lanice@matcha" = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        system = "aarch64-linux";
        config.allowUnfree = true;
      };
      extraSpecialArgs = {inherit inputs;};
      modules = [./home/lanice/matcha.nix];
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
          tags = [];
        };
        imports = [./hosts/unstable];
        time.timeZone = "America/New_York";
      };

      taro = {
        deployment = {
          targetHost = "taro"; # Replace with local network IP if setting up the first time
          targetUser = "lanice";
          # N150 with soldered RAM — let sencha build and push the closure.
          buildOnTarget = false;
          tags = ["homelab"];
        };
        imports = [./hosts/taro];
        time.timeZone = "America/New_York";
      };
    };
  };
}
