# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let
  # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/os-specific/linux/nvidia-x11/default.nix
  # nvidiaPkg =
  #   if (lib.versionOlder nvBeta.version nvStable.version)
  #   then config.boot.kernelPackages.nvidiaPackages.stable
  #   else config.boot.kernelPackages.nvidiaPackages.beta;
  nvidiaPkg = config.boot.kernelPackages.nvidiaPackages.stable;
in {
  # You can import other NixOS modules here
  imports = [
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-pc-ssd
    # This is covered manually now
    # inputs.hardware.nixosModules.common-gpu-nvidia

    ./hardware-configuration.nix

    ../common/global
    ../common/tailscale.nix
    ../common/virtualisation.nix
    ../common/minecraft-servers.nix
    ../common/gnome.nix

    ./secrets.nix
    ./nginx.nix
    # ./dashy.nix
    ./homepage.nix
    ./paperless.nix
    ./media.nix
  ];

  users.users.lanice.shell = lib.mkForce pkgs.bash;

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
    systemPackages = with pkgs; [inputs.agenix.packages.x86_64-linux.default];
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
        "SunsetDragon" = {id = "GQWATA7-Y6EUELT-HZYCAOU-O6AMUID-YIU4AYD-O7QT3V4-ZUE4ZP7-LIITDAE";};
        "S23Ultra" = {id = "IO377ZW-XGOPD22-O6N6B4F-WQJYEYF-2GE463X-DH7MY4M-ZZEQ5CN-T2HJTAC";};
      };

      folders = {
        "sd" = {
          path = "/home/lanice/Sync/sd";
          devices = ["sencha"];
        };
        "sd-misc" = {
          path = "/home/lanice/Sync/sd-misc";
          devices = ["sencha"];
        };
        "stable-diffusion" = {
          path = "/home/lanice/Sync/stable-diffusion";
          devices = ["sencha" "SunsetDragon"];
        };
        "photo-share" = {
          path = "/home/lanice/Sync/photo-share";
          devices = ["sencha" "SunsetDragon"];
        };
        "paperless" = {
          path = "/var/lib/paperless/consume";
          devices = ["sencha" "S23Ultra"];
        };
      };
    };
  };

  # security.polkit.enable = true;
  hardware = {
    graphics.enable = true;
    graphics.extraPackages = [pkgs.vaapiVdpau];

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

  services.displayManager = {
    autoLogin.enable = true;
    autoLogin.user = "lanice";
  };

  services.xserver = {
    displayManager.gdm.wayland = lib.mkForce false;

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

  systemd.services = {
    shutdown-hourly = {
      path = [];
      script = "shutdown -h now";
      serviceConfig.User = "root";
      startAt = "*-*-* *:0";
    };
    shutdown-daily = {
      path = [];
      script = "shutdown -h now";
      serviceConfig.User = "root";
      startAt = "*-*-* 04:00:00";
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
