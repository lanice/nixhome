# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    inputs.hardware.nixosModules.lenovo-thinkpad-p1
    inputs.hardware.nixosModules.common-gpu-nvidia

    inputs.agenix.nixosModules.default
    inputs.solaar.nixosModules.default

    ./hardware-configuration.nix

    ./syncthing.nix
    ./mullvad.nix
    ./nix-ld.nix

    ../common/global
    ../common/tailscale.nix
    ../common/pipewire.nix
    ../common/virtualisation.nix
    ../common/steam.nix

    ../common/cosmic.nix
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

  boot.kernelParams = ["usbcore.autosuspend=-1"];

  powerManagement.powertop.enable = true;

  programs = {
    light.enable = true;
    dconf.enable = true;
  };

  xdg.portal = {
    enable = true;
  };

  hardware = {
    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.beta;
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

  environment = {
    enableAllTerminfo = false;
    systemPackages = with pkgs; [
      # nvtopPackages.full
      libva-utils
      inputs.agenix.packages.x86_64-linux.default
    ];
    sessionVariables.NIXOS_OZONE_WL = "1";
  };

  #  services.blueman.enable = true;

  services.fwupd.enable = true;
  services.flatpak.enable = true;
  services.solaar.enable = true;

  services.tailscale.useRoutingFeatures = "client";

  security.lsm = lib.mkForce []; # https://discourse.nixos.org/t/distrobox-selinux-oci-permission-error/64943/15

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
