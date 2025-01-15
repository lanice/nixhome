{pkgs, ...}: {
  imports = [
    ./font.nix
    ./gtk.nix
    ./playerctl.nix
    ./qt.nix
    ./wofi.nix
    ./zathura.nix
  ];

  home.packages = with pkgs; [pavucontrol qimgv mpv];
}
