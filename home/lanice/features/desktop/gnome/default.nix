{pkgs, ...}: {
  imports = [
    ../common
  ];

  home.packages = with pkgs; [
    gnome.gnome-tweaks # mainly for changing capslock to ctrl
  ];
}
