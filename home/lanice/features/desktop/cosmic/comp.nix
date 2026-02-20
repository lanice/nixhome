{cosmicLib, ...}: let
  mkRON = cosmicLib.cosmic.mkRON;
in {
  wayland.desktopManager.cosmic.compositor = {
    active_hint = true;

    # autotile = true;
    # autotile_behavior = mkRON "enum" "PerWorkspace";

    # workspaces = {
    #   workspace_mode = mkRON "enum" "OutputBound";
    #   workspace_layout = mkRON "enum" "Horizontal";
    # };

    xkb_config = {
      rules = "";
      model = "pc104";
      layout = "us";
      variant = "altgr-intl";
      options = mkRON "optional" "terminate:ctrl_alt_bksp,compose:ralt";
      repeat_delay = 600;
      repeat_rate = 25;
    };

    input_touchpad = {
      state = mkRON "enum" "Enabled";
      scroll_config = mkRON "optional" {
        method = mkRON "optional" null;
        natural_scroll = mkRON "optional" true;
        scroll_button = mkRON "optional" null;
        scroll_factor = mkRON "optional" null;
      };
      tap_config = mkRON "optional" {
        enabled = true;
        button_map = mkRON "optional" (mkRON "enum" "LeftRightMiddle");
        drag = true;
        drag_lock = false;
      };
    };
  };
}
