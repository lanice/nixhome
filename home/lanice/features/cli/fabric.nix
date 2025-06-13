{
  inputs,
  pkgs,
  ...
}: let
  fabric = inputs.fabric.packages.${pkgs.system}.fabric;
in {
  home.packages = [fabric pkgs.yt-dlp];

  programs.fish.functions.yt = ''${fabric}/bin/fabric -y "$argv" --transcript | ${fabric}/bin/fabric -sp summarize'';
}
