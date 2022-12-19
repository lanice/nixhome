{
  description = "Home Manager configuration of lanice";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; # nixpkgs-unstable vs. nixos-unstable ?
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:guibou/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixgl,
    nixpkgs,
    home-manager,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    nixGLOverlay = import ./misc/overlay.nix {package = nixgl;};
    channelsModule = import ./misc/channels.nix {inherit nixpkgs;};
  in {
    homeConfigurations.lanice = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      # Specify your home configuration modules here, for example,
      # the path to your home.nix.
      modules = [
        ./home/home.nix
        nixGLOverlay
        channelsModule
      ];

      # Optionally use extraSpecialArgs
      # to pass through arguments to home.nix
    };
  };
}
