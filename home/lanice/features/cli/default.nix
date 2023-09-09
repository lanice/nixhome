{pkgs, ...}: {
  imports = [
    ./fish.nix
    ./bash.nix
    ./zsh.nix
    ./starship.nix
    ./git.nix
    ./broot.nix
    ./zellij.nix
  ];

  home.packages = with pkgs; [
    comma # Install and run programs by sticking a , before them

    # Rust CLI tools
    bat # Better cat
    bottom # System viewer
    dua # Disk Usage Analyzer
    fd # Better find
    ripgrep # Better grep
    duf # Better df

    htop
    wtf
    lazygit

    # Maybe move into separate 'webdev' feature
    yarn
    pscale

    alejandra # Nix formatter
  ];

  programs.nix-index.enable = true;
  programs.zoxide.enable = true;
  programs.navi.enable = true;

  programs.mcfly = {
    enable = true;
    fuzzySearchFactor = 2;
  };

  home.sessionVariables = {
    MCFLY_RESULTS = 42;
    MCFLY_FUZZY = 2;
    MCFLY_KEY_SCHEME = "emacs";
  };

  programs.eza = {
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

  programs.helix = {
    enable = true;
    settings = {
      theme = "gruvbox";
      editor = {
        line-number = "relative";
        indent-guides.render = true;
      };
    };
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
