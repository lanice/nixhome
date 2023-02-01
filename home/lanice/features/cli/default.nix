{pkgs, ...}: {
  imports = [
    ./bash.nix
    ./zsh.nix
    ./starship.nix
    ./git.nix
  ];

  home.packages = with pkgs; [
    comma # Install and run programs by sticking a , before them

    # Rust CLI tools
    bat # Better cat
    bottom # System viewer
    dua # Disk Usage Analyzer
    fd # Better find
    ripgrep # Better grep

    htop
    wtf
    lazygit

    yarn # Maybe move into separate 'webdev' feature

    alejandra # Nix formatter
  ];

  programs.nix-index.enable = true;
  programs.zoxide.enable = true;
  programs.navi.enable = true;

  programs.mcfly = {
    enable = true;
    fuzzySearchFactor = 2;
  };

  programs.exa = {
    enable = true;
    enableAliases = true; # ls,ll,la,lt,lla
  };

  programs.neovim = {
    enable = true;
    vimAlias = true;
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
  };
}
