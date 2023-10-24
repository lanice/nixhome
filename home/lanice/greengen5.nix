{
  pkgs,
  lib,
  ...
}: let
  whatsapp-wrapped = import ./features/desktop/nixGL/whatsapp.nix {inherit pkgs;};
in {
  imports = [
    ./global # includes features/cli/default.nix
    ./features/email
    ./features/kialo
    ./features/desktop/gnome
    ./features/cli/latex.nix
    ./features/desktop/alacritty/alacritty-wrapped.nix
    ./features/desktop/wezterm # only config files, installed via .deb package now because of nixGl issues
  ];

  home = {
    # Raw configuration files
    # file."<file-in-home>".source = <path-to-file>;

    sessionVariables = {
      EDITOR = "vim";
    };

    packages = with pkgs; [
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

  targets.genericLinux.enable = true;
}
