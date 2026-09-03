{
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    inputs.agenix.homeManagerModules.age

    ./global # includes features/cli,features/helix

    ./features/cli/agents.nix
    ./features/cli/ssh.nix
    ./features/cli/forgejo.nix
    ./features/cli/fabric.nix
    ./features/cli/typst.nix
    ./features/cli/webdev.nix

    # ./features/email
    ./features/distrobox

    ./features/desktop/firefox
    ./features/desktop/zen
    ./features/desktop/zed
    ./features/desktop/ghostty
    ./features/desktop/office

    ./features/desktop/cosmic

    ./themes/catppuccin-mocha
  ];

  browser.default = "zen";

  home = {
    sessionVariables = {
      EDITOR = "hx";
      TERMINAL = "ghostty";
    };

    packages = let
      colmena-unstable = inputs.colmena.packages.${pkgs.stdenv.hostPlatform.system}.colmena;
      dbosctl = inputs.dbosctl.packages.${pkgs.stdenv.hostPlatform.system}.default;
      kenku-fm = inputs.kenku-fm.packages.${pkgs.stdenv.hostPlatform.system}.kenku-fm-experimental;
    in
      with pkgs; [
        slack
        discord
        telegram-desktop
        zoom-us

        google-chrome

        obsidian
        gimp
        lumen

        dbosctl

        sxiv
        # bitwarden-desktop
        xrandr
        python3
        terraform
        colmena-unstable
        prismlauncher
        seventeenlands
        filezilla
        jellyfin-desktop
        feishin
        kooha
        kenku-fm
      ];

    stateVersion = lib.mkDefault "26.05"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  };
}
