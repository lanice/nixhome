# This file (and the global directory) holds config that i use on all hosts
{
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./lanice.nix
    ./fish.nix
    ./locale.nix
    ./nh.nix
    ./nix.nix
    ./systemd-boot.nix
  ];

  home-manager.extraSpecialArgs = {inherit inputs;};

  nixpkgs = {
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        # "pkgname"
        "dotnet-sdk-6.0.428" # Sonarr
        "aspnetcore-runtime-6.0.36" # Sonarr
      ];
    };
  };

  hardware.enableRedistributableFirmware = true;
}
