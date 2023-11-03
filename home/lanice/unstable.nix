{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./global
    ./features/desktop/gnome
    ./features/desktop/alacritty
    ./features/stable-diffusion
  ];

  programs.git.lfs.enable = true;

  home = {
    sessionVariables = {
      EDITOR = "vim";
      TERMINAL = "alacritty";
    };

    packages = with pkgs; [
      # tdesktop
      # firefox
      # discord
      rustup
      distrobox
      multitail
      ccze
      rcon
    ];

    stateVersion = lib.mkDefault "22.05"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  };

  programs.fish.shellAbbrs = {
    mcjournal = "journalctl -fu mc-atm8.service | ${pkgs.ccze}/bin/ccze -A";

    nr = "sudo nixos-rebuild switch --flake .#unstable";
    nrr = "sudo nixos-rebuild switch --flake .#unstable && sudo reboot";
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
