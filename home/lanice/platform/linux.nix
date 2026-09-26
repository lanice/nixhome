# lanice's Linux-only home config; imported for every NixOS host in hosts/common/global/lanice.nix
{
  inputs,
  pkgs,
  ...
}: {
  imports = [./mimeapps.nix];

  home.packages = with pkgs; [
    # TODO: back to features/cli once tokenscope builds on aarch64-darwin
    inputs.tokenscope.packages.${pkgs.stdenv.hostPlatform.system}.tokenscope

    wl-clipboard # Command-line copy/paste utilities for Wayland
    bluetui # TUI for managing bluetooth on Linux
  ];

  xdg.configFile."tokenscope/config.json".text = builtins.toJSON {
    server = "https://tokenscope.lanice.dev";
  };

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
