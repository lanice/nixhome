{pkgs, ...}: {
  imports = [
    ./font.nix
    ./gtk.nix
    ./syncthing.nix
  ];

  home.packages = with pkgs; [
    sublime-merge
    vscode

    obsidian
    spotify
    gimp

    bitwarden
  ];

  programs.zathura.enable = true;
  # programs.rio.enable = true;
}
