{
  config,
  pkgs,
  ...
}: {
  imports = [./alacritty.nix];

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
    # # Disable nvd if there are lesser than 2 profiles in the system.
    # if [ `ls -d1v /nix/var/nix/profiles/per-user/${config.home.username}/home-manager-*-link 2>/dev/null | wc -l ` -lt 2 ];
    # then
    #     return 0
    # fi
    ${pkgs.nvd}/bin/nvd diff $(/usr/bin/ls -d1v /nix/var/nix/profiles/per-user/${config.home.username}/home-manager-*-link | tail -2)
  '';

  # Raw configuration files
  home.file.".config/hstr/config".source = ./home/.config/hstr/config;

  home.packages = with pkgs; [
    # Rust CLI tools
    bat
    bottom
    dua
    fd

    htop
    wtf
    lazygit

    alejandra # Nix formatter
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Some bug with locales: https://github.com/nix-community/home-manager/issues/432#issuecomment-434577486
  programs.man.enable = false;

  programs.zoxide.enable = true;

  programs.exa = {
    enable = true;
    enableAliases = true; # ls,ll,la,lt,lla
  };

  programs.bash = {
    enable = true;

    historySize = 10000;
    historyFileSize = 10000;
    historyControl = ["ignorespace"];

    shellOptions = ["histappend" "checkwinsize" "extglob" "globstar" "checkjobs"];

    sessionVariables = {
      EDITOR = "vim";
    };

    shellAliases = {
      lld = "exa -alF --group-directories-first"; # ls,ll,la,lt,lla - set above (programs.exa.enableAliases)
      cat = "bat";
      hm = "home-manager";
      hms = "home-manager switch";

      # Git
      gs = "git status";
      gf = "git fetch";
      gp = "git pull";
      gd = "git diff";
      gcan = "git commit --amend --no-edit";
      gprf = "git pull --rebase && git forbranch";

      # https://awsu.me/
      awsume = ". awsume";

      at = "alacritty-themes";

      # TODO: Move that stuff elsewhere
      frontend = "yarn watch:webpack";
      "5etools" = "( pushd /media/lanice/DriveOfHolding/5etools && gp && npm run serve:dev && popd )";
    };

    profileExtra = ''
      . "$HOME/.cargo/env"
    '';

    initExtra = ''
      if [ -f ~/.config/hstr/config ]; then
          . ~/.config/hstr/config
      fi

      # NVM
      export NVM_DIR="$HOME/.nvm"
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
      [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

      # Work
      if [ -f ~/.kialo_profile ]; then
          . ~/.kialo_profile
      fi

      # Alacritty bash completion
      source ~/.bash_completion/alacritty
    '';
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      line_break.disabled = true;
      status.disabled = false;
      sudo.disabled = false;

      aws.disabled = true;
      nodejs.disabled = true;
      package.disabled = true;

      memory_usage = {
        disabled = false;
        symbol = " ";
      };

      rust = {
        symbol = " ";
        style = "bold #FF6600";
      };

      character = {
        success_symbol = "[❯](bold blue)";
        error_symbol = "[✗](bold red)";
      };

      git_branch.symbol = " ";
      python.symbol = " ";
      golang.symbol = " ";
      docker_context.symbol = " ";
      java.symbol = " ";
    };
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
}
