{cosmicLib, ...}: let
  mkRON = cosmicLib.cosmic.mkRON;
in {
  wayland.desktopManager.cosmic.panels = [
    {
      name = "Dock";
      anchor = mkRON "enum" "Bottom";
      anchor_gap = true;
      autohide = mkRON "optional" {
        wait_time = 500;
        transition_time = 200;
        handle_size = 2;
      };
      expand_to_edges = false;
      opacity = 0.8;
      output = mkRON "enum" "All";
      background = mkRON "enum" "ThemeDefault";
      size = mkRON "enum" "L";
      margin = 4;
      border_radius = 8;
      exclusive_zone = false;
      layer = mkRON "raw" "Top";
      keyboard_interactivity = mkRON "raw" "OnDemand";
      padding = 0;
      padding_overlap = 0.5;
      spacing = 4;
      size_center = mkRON "optional" null;
      size_wings = mkRON "optional" null;
      autohover_delay_ms = mkRON "optional" 500;

      plugins_center = mkRON "optional" [
        "com.system76.CosmicPanelLauncherButton"
        "com.system76.CosmicPanelWorkspacesButton"
        "com.system76.CosmicPanelAppButton"
        "com.system76.CosmicAppList"
        "com.system76.CosmicAppletMinimize"
      ];
      plugins_wings = mkRON "optional" null;
    }
  ];
}
