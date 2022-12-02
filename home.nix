{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "lanice";
  home.homeDirectory = "/home/lanice";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Some bug with locales: https://github.com/nix-community/home-manager/issues/432#issuecomment-434577486
  programs.man.enable = false;

  # TODO: Move this into programs.bash = { ... } See example: https://github.com/burke/b/blob/master/etc/nix/home.nix
  home.sessionVariables = rec {
    EDITOR = "vim";
  };

  home.packages = with pkgs; [
    # Rust CLI tools
    bat
    bottom
    dua
    exa
    fd

    htop
    wtf
    lazygit
  ];

  # programs.exa = {
  #   enable = true;
  #   enableAliases = true;
  # };

  # programs.zoxide = {
  #   enable = true;
  # };

  # programs.bash = {
  #   enable = true;

  #   historySize = 10000;
  #   historyFileSize = 10000;
  # };

  programs.neovim = {
    enable = true;
    vimAlias = true;
    extraConfig = "colorscheme gruvbox";
    plugins = with pkgs.vimPlugins; [
      vim-nix
      gruvbox
    ];
  };

  programs.git = {
    enable = true;
    userName = "Leander Neiß";
    userEmail = "1871704+lanice@users.noreply.github.com";

    aliases = {
      lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%a │ n>%Creset' --abbrev-commit";
    };

    delta = {
      enable = true;
      options = {
        navigate = true;
        line-numbers = true;
        side-by-side = true;
        syntax-theme = "Monokai Extended Bright";
      };
    };

    extraConfig = {
      init.defaultBranch = "main";
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
    };
  };

  # Raw configuration files
  # home.file.".gitconfig".source = ./backup/.gitconfig;
  home.file.".profile".source = ./home/.profile;
  home.file.".bashrc".source = ./home/.bashrc;
  home.file.".bash_aliases".source = ./home/.bash_aliases;
  home.file.".hstr".source = ./home/.hstr;
}
