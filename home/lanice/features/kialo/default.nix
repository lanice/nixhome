{
  pkgs,
  config,
  ...
}: {
  home.packages = [pkgs.slack];

  programs.bash = {
    shellAliases = {
      # Git forbranch
      gprf = "git pull --rebase && git forbranch";

      frontend = "yarn watch";

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

  programs.fish = {
    shellAbbrs = {
      gprf = "git pull --rebase && git forbranch";

      kialo = "cd $KIALO_ROOT && source ${config.home.homeDirectory}/.virtualenvs/kialo/bin/activate.fish";
      frontend = "yarn watch";
      backend = "$KIALO_ROOT/development/compose/run.py -v";
      backend-lite = "$KIALO_ROOT/development/compose/run.py -mv";
      down = "fish -c 'cd $KIALO_ROOT/development/compose; docker compose down'";
      restart = "fish -c 'cd $KIALO_ROOT/development/compose; docker compose restart'";

      awsume = ". awsume";
    };

    # update development dependencies
    functions = {
      dependencies = ''
        cd $KIALO_ROOT && source ${config.home.homeDirectory}/.virtualenvs/kialo/bin/activate.fish
        yarn
        yarn setup:backend
        rm -rf backend/kialo/__pycache__
        development/compose/build.sh
      '';

      nvm = ''
        fenv source $NVM_DIR/nvm.sh \; nvm $argv
      '';
    };

    interactiveShellInit = ''
      source ${config.home.homeDirectory}/.kialo_profile.fish

      set -gx NVM_DIR $HOME/.nvm

      fenv source $NVM_DIR/nvm.sh

      # NVM
      # fenv export NVM_DIR="$HOME/.nvm"
      # fenv source $NVM_DIR/nvm.sh  # This loads nvm
      # fenv source $NVM_DIR/bash_completion  # This loads nvm bash_completion
    '';
  };

  home.file.".kialo_profile.fish".source = ./.kialo_profile.fish;

  programs.git.aliases.forbranch = "!git push --force origin HEAD:refs/heads/for_$(git rev-parse --symbolic-full-name --abbrev-ref HEAD)_ln";
}
