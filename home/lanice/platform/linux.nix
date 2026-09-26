# lanice's Linux-only home config; imported for every NixOS host in hosts/common/global/lanice.nix
{pkgs, ...}: {
  imports = [./mimeapps.nix];

  home.packages = with pkgs; [
    wl-clipboard # Command-line copy/paste utilities for Wayland
    bluetui # TUI for managing bluetooth on Linux
  ];

  agents.context = ''
    This is a NixOS system.
  '';

  programs.fish.shellAbbrs = {
    nrb = "nh os build";
    nrs = "nh os switch";
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
