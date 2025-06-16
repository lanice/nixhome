{lib, ...}: {
  options.theme = {
    polarity = lib.mkOption {
      type = lib.types.enum ["light" "dark"];
      default = "light";
      description = "Color scheme polarity";
    };
  };
}
