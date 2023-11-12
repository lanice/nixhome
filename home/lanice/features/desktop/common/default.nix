{pkgs, ...}: {
  imports = [
    ./gtk.nix
    ./playerctl.nix
    ./qt.nix
    ./zathura.nix
  ];

  home.packages = with pkgs; [pavucontrol imv mpv];
}
