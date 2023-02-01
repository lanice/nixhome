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

      aptgrade = "sudo apt update && sudo apt upgrade";

      # Git
      gs = "git status";
      gf = "git fetch";
      gp = "git pull";
      gd = "git diff";
      gauc = "git add -u && git commit";
      gcan = "git commit --amend --no-edit";
      gpr = "git pull --rebase";
      # gprf moved to features/kialo

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
    '';
  };
}
