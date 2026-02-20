{...}: {
  xdg.configFile = {
    "cosmic/com.system76.CosmicComp/v1/xkb_config".text = ''
      (
          rules: "",
          model: "pc104",
          layout: "us",
          variant: "altgr-intl",
          options: Some("terminate:ctrl_alt_bksp,compose:ralt"),
          repeat_delay: 600,
          repeat_rate: 25,
      )
    '';

    "cosmic/com.system76.CosmicComp/v1/active_hint".text = "true";

    # "cosmic/com.system76.CosmicComp/v1/autotile".text = "true";
    # "cosmic/com.system76.CosmicComp/v1/autotile_behavior".text = "PerWorkspace";

    # "cosmic/com.system76.CosmicComp/v1/workspaces".text = ''
    #   (
    #       workspace_mode: OutputBound,
    #       workspace_layout: Horizontal,
    #   )
    # '';

    "cosmic/com.system76.CosmicComp/v1/input_touchpad".text = ''
      (
          state: Enabled,
          scroll_config: Some((
              method: None,
              natural_scroll: Some(true),
              scroll_button: None,
              scroll_factor: None,
          )),
          tap_config: Some((
              enabled: true,
              button_map: Some(LeftRightMiddle),
              drag: true,
              drag_lock: false,
          )),
      )
    '';
  };
}
