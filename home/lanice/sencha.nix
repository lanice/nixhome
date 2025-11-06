{
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    inputs.agenix.homeManagerModules.age

    ./global # includes features/cli,features/helix

    ./features/cli/fabric.nix
    ./features/cli/claude-code.nix

    ./features/email
    ./features/maestral
    ./features/distrobox

    ./features/desktop/firefox
    ./features/desktop/vscode
    ./features/desktop/zed
    ./features/desktop/alacritty
    ./features/desktop/ghostty
    ./features/desktop/wezterm
    ./features/desktop/office
    ./features/desktop/matrix
    ./features/desktop/kenku-fm
    ./features/desktop/lutris

    ./features/desktop/gnome

    ./features/espanso

    ./themes/catppuccin-frappe
  ];

  home = {
    sessionVariables = {
      EDITOR = "hx";
      TERMINAL = "ghostty";
    };

    packages = let
      colmena-unstable = inputs.colmena.packages.${pkgs.system}.colmena;
      zen-browser = inputs.zen-browser.packages.${pkgs.system}.zen-browser;
    in
      with pkgs; [
        slack
        discord
        telegram-desktop
        zoom-us
        wasistlos
        fractal

        google-chrome

        obsidian
        spotify
        gimp
        xournalpp
        # gitbutler

        aider-chat

        auth0-cli
        awscli

        sxiv

        bitwarden-desktop

        xorg.xrandr

        python3

        terraform

        colmena-unstable

        prismlauncher
        seventeenlands

        zen-browser

        quickemu

        filezilla
      ];

    stateVersion = lib.mkDefault "23.05"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  };
}
