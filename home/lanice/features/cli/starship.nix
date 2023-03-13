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
    };
  };
}
