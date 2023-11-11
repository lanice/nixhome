# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.hardware.nixosModules.common-gpu-nvidia

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
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
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
  };

  nixpkgs.config.nvidia.acceptLicense = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
