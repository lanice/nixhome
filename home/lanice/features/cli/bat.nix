# {config, ...}:let
#   theme =
#     if config.lib.stylix.....polarity == "light"
#     then "GitHub"
#     else "1337";
# in
{
  programs.bat = {
    enable = true;
    # config = {
    #   theme = theme;
    # };
  };
}
