{
  inputs,
  modulesPath,
  lib,
  pkgs,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    inputs.disko.nixosModules.disko
    inputs.vscode-server.nixosModule

    ./hardware-configuration.nix

    ./disk-config.nix

    ../common/global
    ../common/tailscale.nix
  ];

  boot = {
    loader.systemd-boot.enable = true;
    loader.systemd-boot.configurationLimit = 20;
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

  networking = {
    hostName = "boba";
    networkmanager.enable = true;
  };

  console.keyMap = "us-acentos";

  environment = {
    enableAllTerminfo = true;
    shells = with pkgs; [fish];
    systemPackages = map lib.lowPrio [
      pkgs.curl
      pkgs.gitMinimal
    ];
  };

  users.users.lanice = {
    shell = lib.mkForce pkgs.bash;
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
  };

  system.stateVersion = "25.05";
}
