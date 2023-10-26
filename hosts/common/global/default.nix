# This file (and the global directory) holds config that i use on all hosts
{
  inputs,
  outputs,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./lanice.nix
    ./fish.nix
    ./locale.nix
    ./nix.nix
    ./systemd-boot.nix
  ];

  home-manager.extraSpecialArgs = {inherit inputs outputs;};

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  hardware.enableRedistributableFirmware = true;
}
