{
  pkgs,
  inputs,
  ...
}: let
  localPkgs = inputs.self.packages.${pkgs.stdenv.hostPlatform.system};
in {
  imports = [
    ./neofetch
    ./fish
    ./bash.nix
    ./bat.nix
    ./broot.nix
    ./btop.nix
    ./git.nix
    ./starship.nix
  ];

  home.packages = with pkgs; [
    # Rust CLI tools
    bottom # System viewer
    dua # Disk Usage Analyzer
    fd # Better find
    ripgrep # Better grep
    duf # Better df
    localPkgs.dirstat-rs # Fast, cross-platform disk usage CLI
    dust # A more intuitive version of du in rust

    htop
    lazygit

    devenv

    alejandra # Nix formatter

    wl-clipboard # Command-line copy/paste utilities for Wayland

    bluetui # TUI for managing bluetooth on Linux
  ];

  programs.nix-index.enable = true;
  programs.nix-index-database.comma.enable = true;

  programs.eza.enable = true; # Adds aliases for ls,ll,la,lt,lla
  programs.zoxide.enable = true;
  programs.navi.enable = true;

  programs.atuin = {
    enable = true;
    # daemon.enable = true;
    flags = ["--disable-up-arrow"];
    settings = {
      enter_accept = true;
      records = true;
    };
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraConfig = "colorscheme gruvbox";
    plugins = with pkgs.vimPlugins; [
      vim-nix
      gruvbox
    ];
  };

  programs.tealdeer = {
    enable = true;
    settings = {
      display = {
        compact = false;
        use_pager = false;
      };
      updates = {auto_update = true;};
    };
  };

  programs.rbw = {
    enable = true;
    settings.email = "leanderneiss+bitwarden@gmail.com";
    settings.pinentry = pkgs.pinentry-tty;
  };

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
