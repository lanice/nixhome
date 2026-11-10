{
  config,
  lib,
  cosmicLib,
  ...
}: let
  mkRON = cosmicLib.cosmic.mkRON;
in {
  # https://docs.vicinae.com
  programs.vicinae = {
    enable = true;
    systemd.enable = true;
    # catppuccin sets theme keys; keep settings.json writable from the UI.
    mutableSettings = true;
    # App state churns constantly; each change re-scans the dir (exact-path match, prunes subtree).
    settings.providers.files.preferences.excludedIndexingPaths = map (d: "${config.home.homeDirectory}/${d}") [
      ".claude"
      ".codex"
      ".config"
      ".local"
      ".mozilla"
      ".thunderbird"
      ".agents"
      ".atuin"
      ".bitmonero"
      ".convex"
      ".dbus"
      ".debug"
      ".hyperframes"
      ".librewolf"
      ".omp"
      ".pi"
      ".shared-ringdb"
      ".steam"
      ".t3"
      ".var"
      ".zoom"
      # Bulk generated/scratch trees.
      "dbos/tmp"
      "dev/photos/inkplate/firmware/.arduino"
      "dev/projects/us_historical_directory/evidence/objects"
      "dev/projects/us_historical_directory/research/objects"
    ];
  };

  # Alt+Space is free; COSMIC's own launcher stays on Super / Super+slash.
  wayland.desktopManager.cosmic.shortcuts = lib.mkIf config.desktops.cosmic.enable [
    {
      key = "Alt+space";
      description = mkRON "optional" "Vicinae";
      action = mkRON "enum" {
        variant = "Spawn";
        value = ["${lib.getExe config.programs.vicinae.package} toggle"];
      };
    }
  ];
}
