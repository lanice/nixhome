{
  lib,
  config,
  inputs,
  pkgs,
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

    wallpaper = lib.mkOption {
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

  config = lib.mkMerge [
    {
      catppuccin = {
        enable = true;
        autoEnable = config.theme.catppuccin.enable;
        # nixpkgs' whiskers is on cache.nixos.org; the flake's own gets rebuilt on every nixpkgs bump
        sources = inputs.catppuccin.packages.${pkgs.stdenv.hostPlatform.system}.overrideScope (_: _: {
          whiskers = pkgs.catppuccin-whiskers;
        });
      };
    }
    (lib.mkIf config.theme.catppuccin.enable {
      catppuccin = {
        flavor = config.theme.catppuccin.flavor;
        accent = config.theme.catppuccin.accent;

        firefox.enable = false;
        fish.enable = false; # let fish use terminal colors so it works across SSH
        vscode.profiles.default.enable = false;
      };
    })
  ];
}
