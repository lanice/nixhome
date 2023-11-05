{config, ...}: let
  theme =
    if config.colorscheme.kind == "light"
    then "GitHub"
    else "1337";
in {
  programs.git = {
    enable = true;
    config = {
      theme = theme;
    };
  };
}
