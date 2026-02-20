{cosmicLib, ...}: let
  mkRON = cosmicLib.cosmic.mkRON;
in {
  wayland.desktopManager.cosmic.panels = [
    {
      name = "Panel";
      anchor = mkRON "enum" "Top";
      autohide = mkRON "optional" null;
      margin = 0;
      expand_to_edges = true;
      opacity = 0.8;

      plugins_center = mkRON "optional" [
        "com.system76.CosmicAppletTime"
      ];
      plugins_wings = mkRON "optional" (mkRON "tuple" [
        ["com.system76.CosmicAppletWorkspaces"]
        [
          # "com.system76.CosmicAppletInputSources"
          "com.system76.CosmicAppletStatusArea"
          "com.system76.CosmicAppletNotifications"
          "com.system76.CosmicAppletTiling"
          "com.system76.CosmicAppletNotifications"
          "com.system76.CosmicAppletAudio"
          "com.system76.CosmicAppletBluetooth"
          "com.system76.CosmicAppletNetwork"
          "com.system76.CosmicAppletBattery"
          "com.system76.CosmicAppletPower"
        ]
      ]);
    }
  ];
}
