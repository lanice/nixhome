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
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-gpu-nvidia
    inputs.hardware.nixosModules.common-pc-hdd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
    ../common/tailscale.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays your own flake exports (from overlays dir):
      # outputs.overlays.modifications
      # outputs.overlays.additions

      # Or overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  nix = {
    package = pkgs.nixUnstable;

    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: {flake = value;}) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
    };

    gc = {
      automatic = true;
      dates = "weekly";
    };
  };

  networking.hostName = "unstable";

  boot.loader.grub = {
    enable = true;
    device = "/dev/sdb";
    useOSProber = true;
  };

  # Since we can't manually respond to a panic, just reboot.
  boot.kernelParams = ["panic=1" "boot.panic_on_fail"];

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # X11
  services.xserver.enable = false;

  # Configure console keymap
  console.keyMap = "us-acentos";

  users.users = {
    lanice = {
      isNormalUser = true;
      description = "lanice";
      shell = pkgs.bash;
      openssh.authorizedKeys.keys = [
        # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
      ];
      # TODO: Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
      extraGroups = ["networkmanager" "wheel" "docker"];
    };
  };

  virtualisation.docker.enable = true;

  environment = {
    systemPackages = with pkgs; [];
    enableAllTerminfo = true;
  };

  # Enable automatic login for the user.
  services.getty.autologinUser = "lanice";

  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  services.openssh = {
    enable = true;
    # Forbid root login through SSH.
    settings.PermitRootLogin = "no";
    # Use keys only. Remove if you want to SSH using password (not recommended)
    settings.PasswordAuthentication = false;
  };

  services.vscode-server.enable = true;

  services.syncthing = {
    enable = true;
    user = "lanice";
    dataDir = "/home/lanice/Sync"; # Default folder for new synced folders
    configDir = "/home/lanice/.config/syncthing"; # Folder for Syncthing's settings and keys

    overrideDevices = true; # overrides any devices added or deleted through the WebUI
    overrideFolders = true; # overrides any folders added or deleted through the WebUI

    guiAddress = "0.0.0.0:8384";

    devices = {
      "GreenGen5" = {id = "I6JCY3B-KPPCAXE-IMRWPTB-MGZKKHV-RZIVWRH-AZXD3HA-HM6Z4BL-VF2QVAH";};
      "Orange Laptop" = {id = "P5ZXGOQ-WYCICPY-3ZS7XKZ-6YKJKUD-U5RXUEA-R64HDVZ-4KHAFNA-CMKZIQN";};
    };

    folders = {
      "sd" = {
        path = "/home/lanice/Sync/sd"; # Which folder to add to Syncthing
        devices = ["GreenGen5"]; # Which devices to share the folder with
      };
      "sd-misc" = {
        path = "/home/lanice/Sync/sd-misc"; # Which folder to add to Syncthing
        devices = ["GreenGen5"]; # Which devices to share the folder with
      };
      "stable-diffusion" = {
        path = "/home/lanice/Sync/stable-diffusion"; # Which folder to add to Syncthing
        devices = ["GreenGen5" "Orange Laptop"]; # Which devices to share the folder with
      };
    };
  };

  hardware = {
    opengl.enable = true;
    nvidia.prime.offload.enable = false;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "22.11";
}
