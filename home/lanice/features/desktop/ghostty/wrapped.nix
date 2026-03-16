{
  config,
  pkgs,
  ...
}: {
  imports = [./.];
  programs.ghostty.package = config.lib.nixGL.wrap pkgs.ghostty;
}
