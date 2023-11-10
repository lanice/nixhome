{lib, ...}: {
  options.theme = lib.mkOption {
    type = lib.types.str;
    default = null;
    description = "Theme name from ../../themes/ directory";
    example = "catppuccin-latte";
  };
}
