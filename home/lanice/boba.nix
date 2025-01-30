{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./global

    #./features/desktop/common/font.nix

    #./themes/catppuccin-latte
  ];

  programs.atuin.daemon.enable = true;
  programs.atuin.settings = {enter_accept = true;};

  programs.fish.shellAbbrs = {
    mcjournal = "journalctl -fu podman-minecraft-atm10.service --all | ${pkgs.ccze}/bin/ccze -A";
  };

  home = {
    sessionVariables = {
      EDITOR = "hx";
    };

    packages = with pkgs; [];

    stateVersion = lib.mkDefault "25.05"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  };
}
