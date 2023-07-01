{
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [
        "colored-man-pages"
        "command-not-found"
        "docker"
        "git"
        "npm"
        "pep8"
        "pip"
        "pyenv"
        "python"
        "sudo"
        "systemd"
        "ubuntu"
      ];
      theme = "robbyrussell";
    };
  };
}
