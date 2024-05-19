{pkgs, ...}: {
  imports = [
    ./gtk.nix
    ./playerctl.nix
    ./qt.nix
    ./rofi.nix
    ./zathura.nix
    ./font.nix
  ];

  home.packages = with pkgs; [pavucontrol qimgv mpv];
}
