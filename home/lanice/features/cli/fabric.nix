{pkgs, ...}: let
  fabric = pkgs.fabric-ai;
in {
  home.packages = [fabric pkgs.yt-dlp];

  programs.fish.functions.yt = ''${fabric}/bin/fabric -y "$argv" --transcript | ${fabric}/bin/fabric -sp summarize'';
}
