{pkgs, ...}: {
  imports = [
    ./font.nix
    ./gtk.nix
    ./playerctl.nix
  ];
}
