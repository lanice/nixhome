{lib, ...}: {
  imports = [
    ./global
  ];

  programs.atuin.daemon.enable = true;
  programs.atuin.settings = {enter_accept = true;};

  home = {
    sessionVariables = {
      EDITOR = "hx";
    };

    stateVersion = lib.mkDefault "26.05"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  };
}
