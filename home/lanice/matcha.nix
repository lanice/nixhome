{
  inputs,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./global/home.nix
    ./global/nix.nix

    ./features/cli

    ./features/desktop/common/font.nix
    ./features/desktop/ghostty/wrapped.nix
    ./features/desktop/firefox
    ./features/desktop/vscode
  ];

  targets.genericLinux.nixGL.packages = inputs.nixgl.packages;
  targets.genericLinux.nixGL.defaultWrapper = "mesa";

  programs.ghostty.settings = {
    background-opacity = 0.9;
    window-decoration = "auto";
    command = "fish --login --interactive";
  };

  theme.polarity = "dark";

  home = {
    sessionVariables = {
      EDITOR = "hx";
      TERMINAL = "ghostty";
    };

    packages = let
      zen-browser = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.zen-browser;
    in
      with pkgs; [zen-browser];

    stateVersion = lib.mkDefault "26.05";
  };
}
