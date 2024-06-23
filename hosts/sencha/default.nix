# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    inputs.hardware.nixosModules.lenovo-thinkpad-p1
    inputs.hardware.nixosModules.common-gpu-nvidia

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix

    ./syncthing.nix
    ../common/global
    ../common/tailscale.nix
    ../common/pipewire.nix
    ../common/virtualisation.nix
    ../common/steam.nix

    ../common/gnome.nix
    # ../common/greetd.nix
    # ../common/nvidia.nix
  ];

  networking = {
    hostName = "sencha";
    networkmanager.enable = true;
  };

  # See https://github.com/NixOS/nixpkgs/issues/180175#issuecomment-1473408913
  systemd.services.NetworkManager-wait-online.enable = false;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 30;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;

  powerManagement.powertop.enable = true;

  programs = {
    light.enable = true;
    dconf.enable = true;
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
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
      open = false;
    };
    graphics = {
      enable = true;
      # mesaPackage = pkgs.mesa_23;
    };
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
  };

  environment.systemPackages = with pkgs; [nvtopPackages.full libva-utils];

  #  services.blueman.enable = true;

  services.fwupd.enable = true;
  services.flatpak.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
