{...}: {
  xdg.configFile = {
    "cosmic/com.system76.CosmicPanel.Dock/v1/anchor".text = "Bottom";
    "cosmic/com.system76.CosmicPanel.Dock/v1/anchor_gap".text = "true";

    "cosmic/com.system76.CosmicPanel.Dock/v1/autohide".text = ''
      Some((
          wait_time: 500,
          transition_time: 200,
          handle_size: 2,
      ))
    '';

    "cosmic/com.system76.CosmicPanel.Dock/v1/autohover_delay_ms".text = "Some(500)";
    "cosmic/com.system76.CosmicPanel.Dock/v1/background".text = "ThemeDefault";
    "cosmic/com.system76.CosmicPanel.Dock/v1/border_radius".text = "8";
    "cosmic/com.system76.CosmicPanel.Dock/v1/exclusive_zone".text = "false";
    "cosmic/com.system76.CosmicPanel.Dock/v1/expand_to_edges".text = "false";
    "cosmic/com.system76.CosmicPanel.Dock/v1/keyboard_interactivity".text = "OnDemand";
    "cosmic/com.system76.CosmicPanel.Dock/v1/layer".text = "Top";
    "cosmic/com.system76.CosmicPanel.Dock/v1/margin".text = "4";
    "cosmic/com.system76.CosmicPanel.Dock/v1/name".text = ''"Dock"'';
    "cosmic/com.system76.CosmicPanel.Dock/v1/opacity".text = "0.8";
    "cosmic/com.system76.CosmicPanel.Dock/v1/output".text = "All";
    "cosmic/com.system76.CosmicPanel.Dock/v1/padding".text = "0";
    "cosmic/com.system76.CosmicPanel.Dock/v1/padding_overlap".text = "0.5";

    "cosmic/com.system76.CosmicPanel.Dock/v1/plugins_center".text = ''
      Some([
          "com.system76.CosmicPanelLauncherButton",
          "com.system76.CosmicPanelWorkspacesButton",
          "com.system76.CosmicPanelAppButton",

          "com.system76.CosmicAppList",
          "com.system76.CosmicAppletMinimize",
      ])
    '';

    "cosmic/com.system76.CosmicPanel.Dock/v1/plugins_wings".text = "None";
    "cosmic/com.system76.CosmicPanel.Dock/v1/size".text = "L";
    "cosmic/com.system76.CosmicPanel.Dock/v1/size_center".text = "None";
    "cosmic/com.system76.CosmicPanel.Dock/v1/size_wings".text = "None";
    "cosmic/com.system76.CosmicPanel.Dock/v1/spacing".text = "4";
  };
}
