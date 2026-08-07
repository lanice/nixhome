{lib, ...}: {
  imports = [
    ./global

    #./features/desktop/common/font.nix

    # ./themes/catppuccin-mocha # headless server, themed by SSH terminal
  ];

  programs.atuin.daemon.enable = true;
  programs.atuin.settings = {enter_accept = true;};

  home = {
    sessionVariables = {
      EDITOR = "hx";
    };

    stateVersion = lib.mkDefault "25.05"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  };
}
