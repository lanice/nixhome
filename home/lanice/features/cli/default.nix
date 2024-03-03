{pkgs, ...}: {
  imports = [
    ./kubernetes
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
    dirstat-rs # Fast, cross-platform disk usage CLI

    htop
    wtf
    lazygit

    # Maybe move into separate 'webdev' feature
    yarn
    pscale

    alejandra # Nix formatter
  ];

  programs.nix-index.enable = true;
  programs.nix-index-database.comma.enable = true;

  programs.zoxide.enable = true;
  programs.navi.enable = true;
  programs.thefuck.enable = true;

  programs.atuin = {
    enable = true;
    flags = ["--disable-up-arrow"];
  };

  programs.eza = {
    enable = true;
    enableAliases = true; # ls,ll,la,lt,lla
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
    settings.pinentry = "tty";
  };

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
