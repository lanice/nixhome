{...}: {
  # Default: never suspend or turn off screen (docked).
  # Change via COSMIC Settings when undocked; will reset on next home-manager switch.
  xdg.configFile = {
    "cosmic/com.system76.CosmicIdle/v1/screen_off_time".text = "None";
    "cosmic/com.system76.CosmicIdle/v1/suspend_on_ac_time".text = "None";
    "cosmic/com.system76.CosmicIdle/v1/suspend_on_battery_time".text = "None";
  };
}
