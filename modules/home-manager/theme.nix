{
  lib,
  config,
  inputs,
  ...
}: {
  imports = [inputs.catppuccin.homeModules.catppuccin];

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

    catppuccin = {
      enable = lib.mkEnableOption "catppuccin theming";
      flavor = lib.mkOption {
        type = lib.types.str;
        description = "Catppuccin flavor";
      };
      accent = lib.mkOption {
        type = lib.types.str;
        default = "teal";
        description = "Catppuccin accent color";
      };
    };
  };

  config = lib.mkIf config.theme.catppuccin.enable {
    catppuccin = {
      enable = true;
      flavor = config.theme.catppuccin.flavor;
      accent = config.theme.catppuccin.accent;

      firefox.enable = false;
      # fish.enable = false;
      vscode.profiles.default.enable = false;
    };
  };
}
