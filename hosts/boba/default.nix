{
  inputs,
  modulesPath,
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Used for bootstrap with nixos-anywhere
    # (modulesPath + "/installer/scan/not-detected.nix")
    # (modulesPath + "/profiles/qemu-guest.nix")

    inputs.srvos.nixosModules.server
    inputs.srvos.nixosModules.mixins-terminfo
    inputs.srvos.nixosModules.mixins-nginx
    inputs.srvos.nixosModules.mixins-latest-zfs-kernel

    inputs.disko.nixosModules.disko
    inputs.vscode-server.nixosModule
    inputs.agenix.nixosModules.default

    ./hardware-configuration.nix

    ./disk-config.nix

    ../common/global
    ../common/tailscale.nix

    ./services
  ];

  boot = {
    loader.systemd-boot.enable = true;
    loader.systemd-boot.configurationLimit = 10;
    loader.timeout = 3;
    loader.efi.canTouchEfiVariables = true;

    # Since we can't manually respond to a panic, just reboot.
    kernelParams = ["panic=1" "boot.panic_on_fail"];
  };

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
    settings.PasswordAuthentication = false;
  };
  services.vscode-server.enable = true;

  security.sudo.wheelNeedsPassword = false;

  networking = {
    hostName = "boba";
    hostId = "4bd65d83"; # head -c 8 /etc/machine-id
    networkmanager.enable = true;
  };

  console.keyMap = "us-acentos";
  time.timeZone = "America/New_York";

  environment = {
    enableAllTerminfo = true;
    shells = with pkgs; [fish];
    systemPackages = map lib.lowPrio [
      pkgs.curl
      pkgs.gitMinimal
    ];
  };

  # For initial install. Change password using passwd after first boot, then remove this.
  # users.mutableUsers = lib.mkForce true;
  # users.users.lanice.initialPassword = "password";

  users.users.lanice = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGwdc+uAZvNnh7OTdtIT1ei1n/S+jZdYBZlDXNkNouo2 lanice@sencha"
    ];
  };

  virtualisation = {
    podman = {
      enable = true;
      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;
      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
    oci-containers.backend = "podman";
  };

  system.stateVersion = "25.05";
}
