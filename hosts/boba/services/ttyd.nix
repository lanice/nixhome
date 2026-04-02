{pkgs, ...}: let
  starshipPlainConfig = (pkgs.formats.toml {}).generate "starship-plain.toml" {
    add_newline = true;

    aws.disabled = true;
    nodejs.disabled = true;
    package.disabled = true;

    character = {
      success_symbol = "[>](bold green)";
      error_symbol = "[x](bold red)";
    };

    sudo.disabled = false;

    memory_usage = {
      disabled = false;
      symbol = "mem ";
    };

    rust = {
      symbol = "rs ";
      style = "bold #FF6600";
    };

    shlvl = {
      disabled = false;
      symbol = "^";
    };

    shell = {
      disabled = false;
      fish_indicator = "fish";
    };

    nix_shell = {
      disabled = false;
      impure_msg = "";
      symbol = "nix ";
    };

    hostname.ssh_symbol = "ssh ";
    git_branch.symbol = "git ";
    python.symbol = "py ";
    golang.symbol = "go ";
    docker_context.symbol = "docker ";
    java.symbol = "java ";

    custom = {
      file_number = {
        command = "find . -maxdepth 1 -type f -not -name '.DS_Store' | wc -l";
        when = "exit 0";
        symbol = "f:";
        description = "Number of files in the current working directory";
        format = "[$symbol$output]($style) ";
        style = "fg:yellow bold";
      };

      folder_number = {
        command = "find . -maxdepth 1 -type d -not -name '.git' -not -name '.' | wc -l";
        when = "exit 0";
        symbol = "d:";
        description = "Number of folders in the current working directory";
        format = "[$symbol$output]($style) ";
        style = "fg:yellow bold";
      };
    };
  };

in {
  services.ttyd = {
    enable = true;
    port = 7681;
    writeable = true;
    user = "lanice";
    entrypoint = ["${pkgs.fish}/bin/fish" "--login" "--init-command" "set -gx STARSHIP_CONFIG ${starshipPlainConfig}"];
  };
}
