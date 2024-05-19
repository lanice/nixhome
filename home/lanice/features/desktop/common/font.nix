{pkgs, ...}: {
  fontProfiles = {
    enable = true;
    monospace = {
      family = "GoMono Nerd Font Mono";
      package = pkgs.nerdfonts.override {fonts = ["Go-Mono"];}; # https://github.com/NixOS/nixpkgs/blob/master/pkgs/data/fonts/nerdfonts/shas.nix;
    };
    serif = {
      family = "Iosevka Etoile";
      package = pkgs.iosevka-bin.override {variant = "Etoile";};
    };
    sansSerif = {
      family = "Fira Sans";
      package = pkgs.fira;
    };
    emoji = {
      family = "Noto Color Emoji";
      package = pkgs.noto-fonts-emoji-blob-bin;
    };
  };
}
