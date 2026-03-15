{
  lib,
  pkgs,
  inputs,
  config,
  ...
}: {
  imports = [
    ./mimeapps.nix
    ./home.nix
    ./nix.nix
    ../features/cli
    ../features/helix
  ];
}
