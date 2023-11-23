{config, ...}: let
  light = config.stylix.polarity == "light";
  syntax-theme =
    if light
    then "GitHub"
    else "1337";
in {
  programs.git = {
    enable = true;
    userName = "Leander Neiss";
    userEmail = "1871704+lanice@users.noreply.github.com";

    aliases = {
      lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      file-history = "!f() { git lg --full-history -- $1; }; f";
    };

    delta = {
      enable = true;
      options = {
        navigate = true;
        line-numbers = true;
        side-by-side = false;
        syntax-theme = syntax-theme;
        light = light;
      };
    };

    extraConfig = {
      init.defaultBranch = "main";
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
    };
  };
}
