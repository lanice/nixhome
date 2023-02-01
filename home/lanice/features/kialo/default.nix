{pkgs, ...}: {
  # imports = [
  #   ./something.nix
  # ];

  home.packages = with pkgs; [slack];

  programs.bash = {
    shellAliases = {
      # Git forbranch
      gprf = "git pull --rebase && git forbranch";

      # https://awsu.me/
      awsume = ". awsume";
    };

    initExtra = ''
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

  programs.git.aliases.forbranch = "!git push --force origin HEAD:refs/heads/for_$(git rev-parse --symbolic-full-name --abbrev-ref HEAD)_ln";
}
