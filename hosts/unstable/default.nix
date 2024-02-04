# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/os-specific/linux/nvidia-x11/default.nix
#  nvidiaPkg =
#    if (lib.versionOlder nvBeta.version nvStable.version)
#    then config.boot.kernelPackages.nvidiaPackages.stable
#    else config.boot.kernelPackages.nvidiaPackages.beta;
  nvidiaPkg = config.boot.kernelPackages.nvidiaPackages.latest;
in {
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-pc-ssd
    # This is covered manually now
    # inputs.hardware.nixosModules.common-gpu-nvidia

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix

    ../common/global
    ../common/tailscale.nix
    ../common/virtualisation.nix
    ../common/minecraft-servers.nix
    ../common/gnome.nix
    ../common/steam.nix
    # ../common/sunshine.nix

    ../../themes/catppuccin-latte
  ];

  users.users.lanice.shell = lib.mkForce pkgs.bash;

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

  networking.hostName = "unstable";
  networking.interfaces.eno1.wakeOnLan.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;

  # Since we can't manually respond to a panic, just reboot.
  boot.kernelParams = ["panic=1" "boot.panic_on_fail"];

  networking.networkmanager.enable = true;

  # Configure console keymap
  console.keyMap = "us-acentos";

  environment = {
    shells = with pkgs; [fish];
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

    settings = {
      devices = {
        "sencha" = {id = "4BN4A3S-EUA2SVD-QNEJHI6-LJKBVWW-7FV4YRE-5YOIQBR-A4CWZLB-OQLGBA6";};
        "Orange Laptop" = {id = "P5ZXGOQ-WYCICPY-3ZS7XKZ-6YKJKUD-U5RXUEA-R64HDVZ-4KHAFNA-CMKZIQN";};
        "SunsetDragon" = {id = "GQWATA7-Y6EUELT-HZYCAOU-O6AMUID-YIU4AYD-O7QT3V4-ZUE4ZP7-LIITDAE";};
      };

      folders = {
        "sd" = {
          path = "/home/lanice/Sync/sd"; # Which folder to add to Syncthing
          devices = ["sencha"]; # Which devices to share the folder with
        };
        "sd-misc" = {
          path = "/home/lanice/Sync/sd-misc"; # Which folder to add to Syncthing
          devices = ["sencha"]; # Which devices to share the folder with
        };
        "models" = {
          path = "/home/lanice/Sync/models"; # Which folder to add to Syncthing
          devices = ["sencha"]; # Which devices to share the folder with
        };
        "stable-diffusion" = {
          path = "/home/lanice/Sync/stable-diffusion"; # Which folder to add to Syncthing
          devices = ["sencha" "Orange Laptop" "SunsetDragon"]; # Which devices to share the folder with
        };
        "photo-share" = {
          path = "/home/lanice/Sync/photo-share"; # Which folder to add to Syncthing
          devices = ["sencha" "Orange Laptop" "SunsetDragon"]; # Which devices to share the folder with
        };
      };
    };
  };

  # security.polkit.enable = true;
  hardware = {
    opengl.enable = true;
    opengl.driSupport = true;
    opengl.driSupport32Bit = true;
    opengl.extraPackages = [pkgs.vaapiVdpau];

    nvidia = {
      package = nvidiaPkg;
      open = false;
      modesetting.enable = true;
      nvidiaSettings = false;
      powerManagement.enable = false;
    };
  };

  environment.sessionVariables = {
    WLR_DRM_NO_ATOMIC = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
    LIBVA_DRIVER_NAME = "nvidia";
    MOZ_DISABLE_RDD_SANDBOX = "1";
    # EGL_PLATFORM = "wayland";
  };

  services.xserver = {
    displayManager = {
      gdm.wayland = false;
      autoLogin.enable = true;
      autoLogin.user = "lanice";
    };

    videoDrivers = ["nvidia"];
    # displayManager.setupCommands = "${pkgs.xorg.xrandr}/bin/xrandr --output HDMI-0 --mode 2560x1600";
    displayManager.setupCommands = "xrandr --output HDMI-0 --mode 2560x1440";

    # screenSection = ''
    #   Option "metamodes" "HDMI-0: 2560x1600_60 +0+0, DP-0: 2560x1440_165 +2560+0"
    # '';

    xrandrHeads = [
      {
        output = "HDMI-0";
        primary = true;
        monitorConfig = "DisplaySize 2560 1440";
      }
    ];
  };

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # systemd.services.shutdown-when-idle = {
  #   path = [pkgs.rcon pkgs.gnugrep pkgs.systemd];
  #   script = ''
  #     noPlayers=$(${pkgs.rcon}/bin/rcon -s atm8 list | ${pkgs.gnugrep}/bin/grep "There are 0 of a max of 20 players online" || true)
  #     sessions=$(${pkgs.systemd}/bin/loginctl show-user lanice --property=Sessions --value)
  #     echo $noPlayers
  #     if [[ -n "$noPlayers" ]]; then
  #       echo "No player online."
  #     fi
  #     if [["$sessions" == "1" ]]; then
  #       echo "No user connected via SSH."
  #     fi
  #     if [[ -n "$noPlayers" && "$sessions" == "1" ]]; then
  #       echo "Shutting down."
  #       shutdown -h now
  #     fi
  #     echo "DONE"
  #   '';
  #   serviceConfig.User = "root";
  #   # startAt = "minutely";
  #   # startAt = "*-*-* *:0,30";
  #   startAt = "*-*-* *:0";
  # };

  systemd.services.shutdown-when-idle = {
    path = [];
    script = ''
      shutdown -h now
    '';
    serviceConfig.User = "root";
    startAt = "*-*-* *:0";
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
