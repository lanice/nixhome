{pkgs, ...}: let
  telegram-wrapped = import ./features/desktop/nixGL/telegram.nix {inherit pkgs;};
  whatsapp-wrapped = import ./features/desktop/nixGL/whatsapp.nix {inherit pkgs;};
in {
  imports = [
    ./global
    ./features/email
    ./features/kialo
    ./features/desktop/gnome
    ./features/desktop/alacritty/alacritty-wrapped.nix
  ];

  home = {
    # Raw configuration files
    # file."<file-in-home>".source = <path-to-file>;

    sessionVariables = {
      EDITOR = "vim";
      MCFLY_RESULTS = 42;
    };

    packages = with pkgs; [
      telegram-wrapped
      whatsapp-wrapped
      element-desktop

      # nixgl.nixGL
      nixgl.nixGLIntel
      # nixgl.nixVulkanIntel
      # nixgl.nixGLNvidia
      # nixgl.nixGLNvidiaBumblebee
    ];
  };

  targets.genericLinux.enable = true;
}
