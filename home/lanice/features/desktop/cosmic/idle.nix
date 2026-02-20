{cosmicLib, ...}: let
  mkRON = cosmicLib.cosmic.mkRON;
in {
  # Default: never suspend or turn off screen (docked).
  # Change via COSMIC Settings when undocked; will reset on next home-manager switch.
  wayland.desktopManager.cosmic.idle = {
    screen_off_time = mkRON "optional" null;
    suspend_on_ac_time = mkRON "optional" null;
    suspend_on_battery_time = mkRON "optional" null;
  };
}
