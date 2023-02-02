{pkgs, ...}: {
  imports = [
    ./global
    ./features/desktop/gnome
    ./features/desktop/alacritty
  ];

  home = {
    sessionVariables = {
      EDITOR = "vim";
      MCFLY_RESULTS = 42;
    };

    packages = with pkgs; [
      tdesktop
      firefox
      discord
    ];
  };
}
