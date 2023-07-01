{pkgs, ...}: let
  whatsapp-wrapped = import ./features/desktop/nixGL/whatsapp.nix {inherit pkgs;};
in {
  imports = [
    ./global
    ./features/email
    ./features/kialo
    ./features/desktop/gnome
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
  };

  targets.genericLinux.enable = true;
}
