{package}: {
  config,
  pkgs,
  ...
}: {
  nixpkgs.overlays = [package.overlay];
}
