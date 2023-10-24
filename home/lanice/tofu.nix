{pkgs, ...}: {
  imports = [
    ./global # includes features/cli/default.nix
    # ./features/cli/latex.nix
    ./features/email
    ./features/desktop/alacritty
    # ./features/desktop/wezterm # only config files, installed via .deb package now because of nixGl issues
  ];

  home = {
    sessionVariables = {
      EDITOR = "vim";
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
