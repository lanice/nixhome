{
  inputs,
  pkgs,
  lib,
  ...
}: let
  whatsapp-wrapped = import ./features/desktop/nixGL/whatsapp.nix {inherit pkgs;};
in {
  imports = [
    ./global # includes features/cli,features/helix
    ./features/email
    ./features/kialo
    ./features/misc/latex.nix
    ./features/desktop/gnome
    ./features/desktop/vscode
    ./features/desktop/alacritty/alacritty-wrapped.nix
    ./features/desktop/wezterm # only config files, installed via .deb package now because of nixGl issues
  ];

  # colorscheme = inputs.nix-colors.colorschemes.catppuccin-macchiato;
  colorscheme = inputs.nix-colors.colorschemes.gigavolt;

  home = {
    sessionVariables = {
      EDITOR = "vim";
      TERMINAL = "alacritty";
    };

    packages = with pkgs; [
      sublime-merge

      obsidian
      spotify
      gimp

      bitwarden

      whatsapp-wrapped
      element-desktop

      skypeforlinux

      rcon

      # nixgl.nixGL
      nixgl.nixGLIntel
      # nixgl.nixVulkanIntel
      # nixgl.nixGLNvidia
      # nixgl.nixGLNvidiaBumblebee

      cachix
    ];

    stateVersion = lib.mkDefault "22.05"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  };

  programs.zathura.enable = true;

  services.syncthing = {
    enable = true;
    extraOptions = ["--no-default-folder"];
    tray = {
      enable = true;
      command = "syncthingtray --wait";
    };
  };

  services.xsettingsd.enable = false;

  targets.genericLinux.enable = true;
}
