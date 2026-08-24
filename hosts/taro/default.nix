{
  inputs,
  lib,
  pkgs,
  ...
}: let
  fleet = import ../fleet.nix;
in {
  imports = [
    inputs.srvos.nixosModules.server

    inputs.disko.nixosModules.disko
    inputs.agenix.nixosModules.default

    ./hardware-configuration.nix
    ./disk-config.nix
    ./backup-secrets.nix
    ./backup.nix

    ../common/global
    ../common/tailscale.nix

    ./services
  ];

  networking = {
    hostName = "taro";
    networkmanager.enable = true;
  };

  # Bootloader comes from ../common/global/systemd-boot.nix.
  boot = {
    loader.systemd-boot.configurationLimit = 10;
    loader.timeout = 3;

    # Headless with no console — never sit at a prompt, just reboot.
    kernelParams = ["panic=1" "boot.panic_on_fail"];
    kernel.sysctl."kernel.hung_task_panic" = 1;
  };

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
    settings.PasswordAuthentication = false;
  };

  # Required for colmena, which deploys as lanice.
  security.sudo.wheelNeedsPassword = false;

  users.users.lanice.openssh.authorizedKeys.keys = [
    fleet.users.lanice-sencha
  ];

  console.keyMap = "us-acentos";
  time.timeZone = "America/New_York";

  environment = {
    enableAllTerminfo = false;
    shells = with pkgs; [fish];
    systemPackages = map lib.lowPrio [
      pkgs.curl
      pkgs.gitMinimal
      pkgs.mtr

      pkgs.ghostty.terminfo
      pkgs.foot.terminfo
      pkgs.kitty.terminfo
      pkgs.wezterm.terminfo
      pkgs.alacritty.terminfo
    ];
  };

  system.stateVersion = "26.05";
}
