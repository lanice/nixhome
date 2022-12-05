{nixpkgs}: {config, ...}: {
  # Make sure our global Nix commands use the same nixpkgs as pinned here in our flake (https://ayats.org/blog/channels-to-flakes/)
  xdg.configFile."nix/inputs/nixpkgs".source = nixpkgs.outPath;
  home.sessionVariables.NIX_PATH = "nixpkgs=${config.xdg.configHome}/nix/inputs/nixpkgs$\{NIX_PATH:+:$NIX_PATH}";
  nix.registry.nixpkgs.flake = nixpkgs;
}
