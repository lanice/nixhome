{pkgs, ...}: {
  imports = [
    ../common
    ../alacritty/alacritty-wrapped.nix
  ];

  home.packages = with pkgs; [
    gnome.gnome-tweaks # mainly for changing capslock to ctrl
  ];
}
