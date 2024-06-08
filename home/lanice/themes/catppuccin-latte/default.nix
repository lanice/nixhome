{
  lib,
  pkgs,
  ...
}: {
  imports = [../stylix.nix];

  theme = "catppuccin-latte";

  stylix = {
    base16Scheme = ./base16.yaml;
    polarity = "light";

    image = pkgs.fetchurl {
      url = "https://i.postimg.cc/TGrLzsD8/dogsplayingpoker.png";
      sha256 = "sha256-51c5vQfcfD73BEdqfNxOcEkpgFSHC6u4eMqOVKJq9SY=";
    };

    cursor = {
      name = "catppuccin-latte-light-cursors";
      package = pkgs.catppuccin-cursors.latteLight;
    };

    targets.vscode.enable = false;
    targets.rofi.enable = false;
  };

  programs.vscode = {
    userSettings."workbench.colorTheme" = "Catppuccin Latte";
    userSettings."workbench.iconTheme" = "catppuccin-latte";
  };

  programs.btop.settings = {
    color_theme = lib.mkForce "catppuccin-latte";
  };
  home.file.".config/btop/themes/catppuccin-latte.theme".source = ./btop-catppuccin-latte.theme;

  programs.rofi.theme = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/catppuccin/rofi/main/basic/.local/share/rofi/themes/catppuccin-latte.rasi";
    sha256 = "sha256:1qkb19lpl2qpfvxyyw0rp05k92al2m7s59rpxpmmf99rblgs9313";
  };

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
}
