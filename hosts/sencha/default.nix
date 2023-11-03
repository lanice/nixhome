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
    ../common/gnome.nix
    #    ../common/nvidia.nix
    #    ../common/greetd.nix
    ../common/tailscale.nix

    # ./syncthing.nix
  ];

  nixpkgs = {
    overlays = [];
    config.allowUnfree = true;
  };

  networking = {
    hostName = "sencha";
    networkmanager.enable = true;
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;

  powerManagement.powertop.enable = true;

  programs = {
    dconf.enable = true;
  };

  hardware = {
    nvidia = {
      prime = {
        offload.enable = false;
        sync.enable = true;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:01:0:0";
      };
      modesetting.enable = true;
      open = true;
    };
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      #      mesaPackage = pkgs.mesa_23;
    };
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
  };

  #  services.blueman.enable = true;

  services.fwupd.enable = true;
  services.flatpak.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
