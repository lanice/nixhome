{...}: {
  xdg.configFile = {
    "cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom".text = ''
      {
          (modifiers: [Super], key: "Return"): System(Terminal),
      }
    '';
    "cosmic/com.system76.CosmicSettings.Shortcuts/v1/system_actions".text = ''
      {
          Terminal: "ghostty",
      }
    '';
  };
}
