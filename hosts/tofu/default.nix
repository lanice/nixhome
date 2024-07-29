# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.hardware.nixosModules.common-gpu-nvidia

    ./hardware-configuration.nix

    ../common/global
    ../common/nvidia.nix
    ../common/greetd.nix
    ../common/tailscale.nix
  ];

  networking = {
    hostName = "tofu";
    networkmanager.enable = true;
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_1;

  boot.kernelParams = ["i915.force_probe=46a6"];
  boot.blacklistedKernelModules = ["nouveau"];
  services.xserver.videoDrivers = ["nvidia"];

  powerManagement.powertop.enable = true;

  programs = {
    dconf.enable = true;
  };

  hardware = {
    nvidia = {
      prime = {
        offload.enable = false;
        #  sync.enable = true;
        #  intelBusId = "PCI:0:2:0";
        #  nvidiaBusId = "PCI:1:0:0";
      };
      package = config.boot.kernelPackages.nvidiaPackages.legacy_340;
      modesetting.enable = true;
      powerManagement.enable = false;
    };
    graphics = {
      enable = true;
    };
  };

  nixpkgs.config.nvidia.acceptLicense = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
