{lib, ...}: {
  options.theme = lib.mkOption {
    type = lib.types.str;
    default = null;
    description = "Theme name from home/lanice/themes/ directory";
    example = "catppuccin-latte";
  };
}
