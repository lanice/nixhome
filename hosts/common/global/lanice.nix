{
  pkgs,
  config,
  ...
}: let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  users.mutableUsers = true;
  users.users.lanice = {
    isNormalUser = true;
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
      ];

    packages = [pkgs.home-manager];
  };

  home-manager.users.lanice = import ../../../home/lanice/${config.networking.hostName}.nix;
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  security.pam.services = {swaylock = {};};
}
