{pkgs, ...}: {
  fontProfiles = {
    enable = true;
    monospace = {
      family = "GoMono Nerd Font Mono";
      package = pkgs.nerdfonts.override {fonts = ["Go-Mono"];}; # https://github.com/NixOS/nixpkgs/blob/master/pkgs/data/fonts/nerdfonts/shas.nix
    };
    regular = {
      family = "Fira Sans";
      package = pkgs.fira;
    };
  };
}
