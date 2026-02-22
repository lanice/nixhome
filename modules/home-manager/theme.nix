{lib, ...}: {
  options.theme = {
    polarity = lib.mkOption {
      type = lib.types.enum ["light" "dark"];
      default = "light";
      description = "Color scheme polarity";
    };

    cosmic.ronFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
    };
  };
}
