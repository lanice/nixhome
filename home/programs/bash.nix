{
  programs.bash = {
    enable = true;

    historySize = 10000;
    historyFileSize = 10000;
    historyControl = ["ignorespace"];

    shellOptions = ["histappend" "checkwinsize" "extglob" "globstar" "checkjobs"];

    # sessionVariables = {};

    shellAliases = {
      lld = "exa -alF --group-directories-first"; # ls,ll,la,lt,lla - set above (programs.exa.enableAliases)
      cat = "bat";
      hm = "home-manager";
      hms = "home-manager switch --flake $HOME/nixhome/";

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
    };

    profileExtra = ''
      . "$HOME/.cargo/env"
    '';

    initExtra = ''
      # Local stuff
      if [ -f ~/.env ]; then
          . ~/.env
      fi

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
    '';
  };
}
