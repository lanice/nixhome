{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [../stylix.nix];

  config.theme = "catppuccin-latte";

  config.home-manager.users.lanice = {
    programs.vscode = {
      userSettings.workbench.colorTheme = lib.mkForce "Catppuccin Latte";
      userSettings.workbench.iconTheme = lib.mkForce "catppuccin-latte";
      extensions = with pkgs.vscode-extensions; [
        catppuccin.catppuccin-vsc
        catppuccin.catppuccin-vsc-icons
      ];
    };

    programs.btop.settings = {
      color_theme = lib.mkForce "catppuccin-latte";
    };
    home.file.".config/btop/themes/catppuccin-latte.theme".source = ./btop-catppuccin-latte.theme;

    # Seems not to work atm
    # programs.discocss = {
    #   enable = true;

    #   package = pkgs.discocss.overrideAttrs (old: rec {
    #     version = "0.3.1";
    #     src = pkgs.fetchFromGitHub {
    #       owner = "bddvlpr";
    #       repo = "discocss";
    #       rev = "v${version}";
    #       hash = "sha256-BFTxgUy2H/T92XikCsUMQ4arPbxf/7a7JPRewGqvqZQ=";
    #     };
    #   });
    #   # discord = pkgs.discord.override {withOpenASAR = true;};
    #   discordPackage = pkgs.discord.override {withVencord = true;};

    #   css = builtins.readFile (builtins.fetchurl {
    #     url = "https://catppuccin.github.io/discord/dist/catppuccin-latte.theme.css";
    #     sha256 = "sha256:029lx97181gs69r0g9amxcpnvsyixxqsf3fxi2vmnabriz03ji10";
    #   });
    # };
  };
}
