{
  config,
  lib,
  pkgs,
  ...
}: {
  # General documentation: https://nixos.wiki/wiki/Visual_Studio_Code
  # Options: https://nix-community.github.io/home-manager/options.html#opt-programs.vscode.enable
  programs.vscode = {
    enable = true;
    mutableExtensionsDir = false;
    enableUpdateCheck = false;
    enableExtensionUpdateCheck = true;

    keybindings = import ./keybindings.nix;
    userSettings = import ./user-settings.nix {fontFamily = config.stylix.fonts.monospace.name;};
    extensions = import ./extensions.nix {inherit pkgs;};
  };
}
