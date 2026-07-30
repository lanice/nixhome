{
  pkgs,
  config,
  lib,
  ...
}: let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  users.mutableUsers = lib.mkDefault true;
  users.users.lanice = {
    isNormalUser = true;
    # Pinned: the allocation lives only in /var/lib/nixos/uid-map, so a rebuild
    # from scratch would not reproduce it, and it is not knowable at evaluation
    # time while unset. All hosts already allocated 1000.
    uid = 1000;
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [];
    extraGroups =
      [
        "networkmanager"
        "wheel"
        "video"
        "audio"
      ]
      ++ ifTheyExist [
        "mysql"
        "docker"
        "podman"
        "git"
        "gamemode"
      ];

    packages = [pkgs.home-manager];
  };

  home-manager.users.lanice = import ../../../home/lanice/${config.networking.hostName}.nix;
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  # home-manager.backupFileExtension = "bak";

  security.pam.services = {swaylock = {};};
}
