{pkgs, ...}: {
  imports = [
    ./font.nix
    ./syncthing.nix
  ];

  home.packages = with pkgs; [
    sublime-merge
    vscode

    obsidian
    # spotify
    gimp

    bitwarden
  ];

  programs.zathura.enable = true;
}
