# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  telegram-wrapped = import ./programs/nixGL/telegram.nix {inherit pkgs;};
  whatsapp-wrapped = import ./programs/nixGL/whatsapp.nix {inherit pkgs;};
  nerdfont-overrides = pkgs.nerdfonts.override {fonts = ["Go-Mono"];}; # https://github.com/NixOS/nixpkgs/blob/master/pkgs/data/fonts/nerdfonts/shas.nix
in {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
    ./programs
    ./features
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays your own flake exports (from overlays dir):
      # outputs.overlays.modifications
      # outputs.overlays.additions

      # Or overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  home = {
    username = "lanice";
    homeDirectory = "/home/lanice";

    activation.report-changes = config.lib.dag.entryAnywhere ''
      ${pkgs.nvd}/bin/nvd diff $(/usr/bin/ls -d1v /nix/var/nix/profiles/per-user/${config.home.username}/home-manager-*-link | tail -2)
    '';

    # Raw configuration files
    # file."<file-in-home>".source = <path-to-file>;

    sessionVariables = {
      EDITOR = "vim";
      MCFLY_RESULTS = 42;
    };

    packages = with pkgs; [
      # Rust CLI tools
      bat
      bottom
      dua
      fd
      ripgrep

      # nixgl.nixGL
      nixgl.nixGLIntel
      # nixgl.nixVulkanIntel
      # nixgl.nixGLNvidia
      # nixgl.nixGLNvidiaBumblebee

      nerdfont-overrides

      htop
      wtf
      lazygit

      yarn
      # docker
      sublime-merge
      vscode
      slack

      obsidian
      spotify

      telegram-wrapped
      whatsapp-wrapped
      element-desktop

      bitwarden

      alejandra # Nix formatter
    ];
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  # home.packages = with pkgs; [ steam ];

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;

  # Some bug with locales: https://github.com/nix-community/home-manager/issues/432#issuecomment-434577486
  # programs.man.enable = false;

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

  programs.rbw = {
    enable = true;
    settings.email = "leanderneiss+bitwarden@gmail.com";
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  targets.genericLinux.enable = true;

  fonts.fontconfig.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "22.05";
}
