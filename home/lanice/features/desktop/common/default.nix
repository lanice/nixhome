{pkgs, ...}: {
  imports = [
    ./font.nix
    ./gtk.nix
    ./playerctl.nix
    ./qt.nix
  ];

  home.packages = with pkgs; [pavucontrol];
}
