{
  programs.git = {
    enable = true;
    userName = "Leander Neiß";
    userEmail = "1871704+lanice@users.noreply.github.com";

    aliases = {
      lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
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
