{
  pkgs,
  inputs,
  ...
}: let
  localPkgs = inputs.self.packages.${pkgs.system};
in {
  imports = [
    ./neofetch
    ./zellij
    ./bash.nix
    ./bat.nix
    ./broot.nix
    ./btop.nix
    ./fish.nix
    ./git.nix
    ./starship.nix
    ./zsh.nix
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

    # Maybe move into separate 'webdev' feature
    yarn
    bun
    nodejs_20
    nodejs_20.pkgs.pnpm

    devenv

    alejandra # Nix formatter

    wl-clipboard # Command-line copy/paste utilities for Wayland
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
