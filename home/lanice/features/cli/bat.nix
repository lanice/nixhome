{config, ...}: let
  theme =
    if config.colorscheme.kind == "light"
    then "GitHub"
    else "1337";
in {
  programs.bat = {
    enable = true;
    config = {
      theme = theme;
    };
  };
}
