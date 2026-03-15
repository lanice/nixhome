{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./global/home.nix
    ./global/nix.nix

    ./features/cli

    ./features/desktop/common/font.nix
    ./features/desktop/ghostty
    ./features/desktop/firefox
    ./features/desktop/vscode
  ];

  home = {
    sessionVariables = {
      EDITOR = "hx";
      TERMINAL = "ghostty";
    };

    packages = with pkgs; [];

    stateVersion = lib.mkDefault "26.05";
  };
}
