{cosmicLib, ...}: let
  mkRON = cosmicLib.cosmic.mkRON;
in {
  wayland.desktopManager.cosmic.shortcuts = [
    {
      key = "Super+Return";
      action = mkRON "enum" {
        variant = "System";
        value = [(mkRON "enum" "Terminal")];
      };
    }
  ];

  wayland.desktopManager.cosmic.systemActions = mkRON "map" [
    {
      key = mkRON "enum" "Terminal";
      value = "ghostty";
    }
  ];
}
