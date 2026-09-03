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
    ./features/cli/zellij
    ./features/cli/fabric.nix
    ./features/cli/forgejo.nix
    ./features/cli/typst.nix
    ./features/cli/webdev.nix
    ./features/cli/zsh.nix

    ./features/email
    ./features/maestral
    ./features/distrobox

    ./features/desktop/firefox
    ./features/desktop/zen
    ./features/desktop/vscode
    ./features/desktop/zed
    ./features/desktop/alacritty
    ./features/desktop/ghostty
    ./features/desktop/wezterm
    ./features/desktop/office
    ./features/desktop/matrix

    ./features/desktop/cosmic
    ./features/desktop/gnome

    # ./features/espanso

    ./themes/catppuccin-macchiato
  ];

  browser.default = "firefox";

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
        karere

        google-chrome

        obsidian
        spotify
        gimp
        xournalpp
        # gitbutler
        lumen

        auth0-cli
        awscli
        dbosctl

        sxiv
        # bitwarden-desktop
        xrandr
        python3
        terraform
        colmena-unstable
        prismlauncher
        seventeenlands
        quickemu
        filezilla
        jellyfin-desktop
        feishin
        kooha
        ryubing
        kenku-fm
      ];

    stateVersion = lib.mkDefault "23.05"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  };
}
