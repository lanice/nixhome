{pkgs, ...}: {
  home.packages = [
    (pkgs.nerdfonts.override {fonts = ["Go-Mono"];}) # https://github.com/NixOS/nixpkgs/blob/master/pkgs/data/fonts/nerdfonts/shas.nix
  ];

  fonts.fontconfig.enable = true;
}
