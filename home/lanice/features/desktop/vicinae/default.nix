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
