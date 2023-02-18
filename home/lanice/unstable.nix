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

  home = {
    sessionVariables = {
      EDITOR = "vim";
      MCFLY_RESULTS = 42;
    };

    packages = with pkgs; [
      # tdesktop
      # firefox
      # discord
      rustup
    ];
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
