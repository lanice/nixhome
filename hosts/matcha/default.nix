# MacBook M1 Pro, macOS + nix-darwin
{
  inputs,
  pkgs,
  ...
}: let
  fleet = import ../fleet.nix;
in {
  imports = [
    inputs.home-manager.darwinModules.home-manager
    ../common/global/fish.nix
    ../common/global/nix.nix
  ];

  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config.allowUnfree = true;
  };

  networking = {
    hostName = "matcha";
    computerName = "matcha";
  };

  system.primaryUser = "lanice";

  # knownUsers lets nix-darwin set the login shell. 501 = first macOS user;
  # on mismatch activation warns and skips the user.
  users.knownUsers = ["lanice"];
  users.users.lanice = {
    uid = 501;
    home = "/Users/lanice";
    shell = pkgs.fish;
    # herdr clients attach over SSH (docs/runbooks/matcha.md)
    openssh.authorizedKeys.keys = [
      fleet.users.lanice-sencha
      fleet.users.lanice-longjing
    ];
  };

  services.openssh = {
    enable = true;
    extraConfig = ''
      PasswordAuthentication no
      KbdInteractiveAuthentication no
    '';
  };

  # Standalone Tailscale app (Tailscale's recommended macOS variant): full
  # MagicDNS incl. short names. Homebrew itself is installed manually.
  homebrew = {
    enable = true;
    casks = ["tailscale-app"];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {inherit inputs;};
    users.lanice.imports = [
      ../../home/lanice/matcha.nix
      ../../home/lanice/platform/darwin.nix
    ];
  };

  nix = {
    # auto-optimise-store corrupts the store on darwin (nix-darwin asserts)
    settings.auto-optimise-store = false;
    optimise.automatic = true;
    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    };
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  system.stateVersion = 6;
}
