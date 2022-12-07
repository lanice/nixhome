{
  config,
  pkgs,
  lib,
  ...
}: let
  telegram-wrapped = import ./programs/nixGL/telegram.nix {inherit pkgs;};
  whatsapp-wrapped = import ./programs/nixGL/whatsapp.nix {inherit pkgs;};
  nerdfont-overrides = pkgs.nerdfonts.override {fonts = ["Go-Mono"];}; # https://github.com/NixOS/nixpkgs/blob/master/pkgs/data/fonts/nerdfonts/shas.nix
in {
  # See https://github.com/nix-community/home-manager/issues/2942
  # nixpkgs.config.allowUnfreePredicate = _: true;
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "obsidian"
      "spotify"
      "google-chrome"
      "sublime-merge"
    ];

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

  home.activation.report-changes = config.lib.dag.entryAnywhere ''
    ${pkgs.nvd}/bin/nvd diff $(/usr/bin/ls -d1v /nix/var/nix/profiles/per-user/${config.home.username}/home-manager-*-link | tail -2)
  '';

  # Raw configuration files
  # home.file."<file-in-home>".source = <path-to-file>;
  home.file.".config/nix/nix.conf".source = .config/nix/nix.conf;

  targets.genericLinux.enable = true;

  fonts.fontconfig.enable = true;

  home.sessionVariables = {
    EDITOR = "vim";
    MCFLY_RESULTS = 42;
  };

  home.packages = with pkgs; [
    # Rust CLI tools
    bat
    bottom
    dua
    fd
    ripgrep

    # nixgl.nixGL
    # nixgl.nixGLIntel
    # nixgl.nixVulkanIntel
    # nixgl.nixGLNvidia
    # nixgl.nixGLNvidiaBumblebee

    nerdfont-overrides

    htop
    wtf
    lazygit

    sublime-merge

    obsidian
    spotify
    google-chrome

    telegram-wrapped
    whatsapp-wrapped
    element-desktop

    bitwarden

    alejandra # Nix formatter
  ];

  imports = [./programs];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Some bug with locales: https://github.com/nix-community/home-manager/issues/432#issuecomment-434577486
  programs.man.enable = false;

  programs.zoxide.enable = true;
  programs.zathura.enable = true;
  programs.mcfly = {
    enable = true;
    fuzzySearchFactor = 2;
  };
  programs.navi.enable = true;

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
}
