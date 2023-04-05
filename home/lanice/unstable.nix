{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./global
    # ./features/desktop/gnome
    # ./features/desktop/alacritty
    ./features/stable-diffusion
  ];

  programs.git.lfs.enable = true;

  home = {
    sessionVariables = {
      EDITOR = "vim";
    };

    packages = with pkgs; [
      # tdesktop
      # firefox
      # discord
      rustup
      distrobox
    ];
  };

  programs.fish.shellAbbrs = {
    mcjournal = "journalctl -fu mc-e2es.service | ${pkgs.ccze}/bin/ccze";
  };

  # dconf.settings = {
  #   "org/gnome/settings-daemon/plugins/media-keys" = {
  #     custom-keybindings = [
  #       "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
  #     ];
  #   };

  #   "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
  #     binding = "<Control><Alt>t";
  #     command = "alacritty";
  #     name = "open-terminal";
  #   };
  # };
}
