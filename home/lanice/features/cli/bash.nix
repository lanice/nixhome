{
  programs.bash = {
    enable = true;

    historySize = 10000;
    historyFileSize = 10000;
    historyControl = ["ignorespace"];

    shellOptions = ["histappend" "checkwinsize" "extglob" "globstar" "checkjobs"];

    shellAliases = {
      aptgrade = "sudo apt update && sudo apt upgrade";

      lld = "eza -alF --group-directories-first"; # ls,ll,la,lt,lla - set with eza (programs.eza.enableAliases)
      cat = "bat";
      hm = "home-manager";
      hms = "home-manager --flake . switch";

      # Git
      gs = "git status";
      gf = "git fetch";
      gp = "git pull";
      gd = "git diff";
      gauc = "git add -u && git commit";
      gcan = "git commit --amend --no-edit";
      gpr = "git pull --rebase";
      # gprf moved to features/kialo
    };

    profileExtra = ''
      if [ -f ~/.cargo/env ]; then
        . ~/.cargo/env
      fi
    '';

    initExtra = ''
      # Local stuff
      if [ -f ~/.env ]; then
          . ~/.env
      fi
    '';
  };
}
