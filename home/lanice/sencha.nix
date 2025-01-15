{
  pkgs,
  lib,
  inputs,
  ...
}: let
  localPkgs = inputs.self.packages.${pkgs.system};
in {
  imports = [
    inputs.agenix.homeManagerModules.age

    ./global # includes features/cli,features/helix
    ./features/email
    ./features/maestral
    ./features/distrobox
    ./features/desktop/firefox
    ./features/desktop/vscode
    ./features/desktop/alacritty
    ./features/desktop/wezterm
    ./features/desktop/office
    ./features/desktop/matrix

    ./features/desktop/gnome

    ./themes/catppuccin-latte
  ];

  home = {
    sessionVariables = {
      EDITOR = "hx";
      TERMINAL = "alacritty";
    };

    packages = with pkgs; [
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

      fabric-ai
      aider-chat
      localPkgs.claude-desktop

      auth0-cli
      awscli

      sxiv

      bitwarden

      xorg.xrandr

      python3

      terraform
    ];

    stateVersion = lib.mkDefault "23.05"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  };
}
