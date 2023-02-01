{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  telegram-wrapped = import ./features/desktop/nixGL/telegram.nix {inherit pkgs;};
in {
  imports = [
    ./global
    ./features/desktop/gnome
  ];

  home = {
    sessionVariables = {
      EDITOR = "vim";
      MCFLY_RESULTS = 42;
    };

    packages = with pkgs; [
      telegram-wrapped
    ];
  };

  targets.genericLinux.enable = true;
}
