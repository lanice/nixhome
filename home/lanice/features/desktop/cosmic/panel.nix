{...}: {
  xdg.configFile = {
    "cosmic/com.system76.CosmicPanel/v1/entries".text = ''
      [
          "Panel",
          "Dock",
      ]
    '';
    "cosmic/com.system76.CosmicPanel.Panel/v1/anchor".text = "Top";
    "cosmic/com.system76.CosmicPanel.Panel/v1/opacity".text = "0.8";
    "cosmic/com.system76.CosmicPanel.Panel/v1/expand_to_edges".text = "true";
    "cosmic/com.system76.CosmicPanel.Panel/v1/autohide".text = "None";
    "cosmic/com.system76.CosmicPanel.Panel/v1/plugins_center".text = ''
      Some([
          "com.system76.CosmicAppletTime",
      ])
    '';
    "cosmic/com.system76.CosmicPanel.Panel/v1/plugins_wings".text = ''
      Some(([
          "com.system76.CosmicAppletWorkspaces",
      ], [
          # "com.system76.CosmicAppletInputSources",
          "com.system76.CosmicAppletStatusArea",
          "com.system76.CosmicAppletNotifications",
          "com.system76.CosmicAppletTiling",
          "com.system76.CosmicAppletNotifications",
          "com.system76.CosmicAppletAudio",
          "com.system76.CosmicAppletBluetooth",
          "com.system76.CosmicAppletNetwork",
          "com.system76.CosmicAppletBattery",
          "com.system76.CosmicAppletPower",
      ]))
    '';
  };
}
