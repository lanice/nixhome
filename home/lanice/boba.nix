{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./global

    ./features/desktop/common/font.nix

    ./themes/catppuccin-latte
  ];

  home = {
    sessionVariables = {
      EDITOR = "hx";
    };

    packages = with pkgs; [];

    stateVersion = lib.mkDefault "24.11"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  };
}
