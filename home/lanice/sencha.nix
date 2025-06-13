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

    ./features/email
    ./features/maestral
    ./features/distrobox

    ./features/desktop/firefox
    ./features/desktop/vscode
    ./features/desktop/alacritty
    ./features/desktop/wezterm
    ./features/desktop/office
    ./features/desktop/matrix
    ./features/desktop/kenku-fm

    ./features/desktop/gnome

    ./features/espanso

    ./themes/catppuccin-latte
  ];

  home = {
    sessionVariables = {
      EDITOR = "hx";
      TERMINAL = "alacritty";
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
        whatsapp-for-linux
        fractal
        gfn-electron # geforce now

        google-chrome

        obsidian
        spotify
        gimp
        xournalpp
        zed-editor
        # gitbutler

        aider-chat
        claude-code

        auth0-cli
        awscli

        sxiv

        bitwarden

        xorg.xrandr

        python3

        terraform

        colmena-unstable

        prismlauncher

        zen-browser
      ];

    stateVersion = lib.mkDefault "23.05"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  };
}
