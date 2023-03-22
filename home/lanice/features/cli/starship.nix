{
  programs.starship = {
    enable = true;
    enableZshIntegration = false;
    settings = {
      add_newline = true;
      line_break.disabled = false;
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
        success_symbol = "[❯](bold green)";
        error_symbol = "[✗](bold red)";
      };

      shlvl = {
        disabled = false;
        symbol = "ﰬ";
      };

      shell = {
        disabled = false;
        fish_indicator = "";
      };

      nix_shell = {
        disabled = false;
        impure_msg = "";
        symbol = "❄️";
      };

      hostname.ssh_symbol = " ";

      git_branch.symbol = " ";
      python.symbol = " ";
      golang.symbol = " ";
      docker_context.symbol = " ";
      java.symbol = " ";

      # right_format = "$git_branch";

      custom = {
        file_number = {
          command = "find . -maxdepth 1 -type f -not -name '.DS_Store' | wc -l";
          when = "exit 0"; # run always
          symbol = " ";
          description = "Number of files in the current working directory";
          format = "[$symbol$output]($style) ";
          style = "fg:yellow bold"; # terminus different
        };

        folder_number = {
          command = "find . -maxdepth 1 -type d -not -name '.git' -not -name '.' | wc -l";
          when = "exit 0";
          symbol = " ";
          description = "Number of folders in the current working directory";
          format = "[$symbol$output]($style) ";
          style = "fg:yellow bold"; # terminus different
        };

        # distrobox: https://github.com/starship/starship/discussions/1252#discussioncomment-2622328
      };
    };
  };
}
