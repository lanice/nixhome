{pkgs, ...}: {
  imports = [
    ./global # includes features/cli,features/helix
    ./features/desktop/hyprland
    ./features/desktop/alacritty
  ];

  home = {
    sessionVariables = {
      EDITOR = "vim";
      TERMINAL = "alacritty";
    };

    packages = with pkgs; [
      firefox
      sublime-merge
      vscode

      slack
      discord
      telegram-desktop

      obsidian
      spotify
      gimp

      bitwarden

      # whatsapp-for-linux
      # element-desktop
      # skypeforlinux

      # rcon

      # cachix
    ];

    stateVersion = lib.mkDefault "23.05"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  };
}
