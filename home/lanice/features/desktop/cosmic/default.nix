{
  inputs,
  config,
  lib,
  cosmicLib,
  ...
}: let
  mkRON = cosmicLib.cosmic.mkRON;
  importRON = cosmicLib.cosmic.importRON;
in {
  imports = [
    inputs.cosmic-manager.homeManagerModules.cosmic-manager
    ../common
  ];

  services.xsettingsd.enable = false;

  # NOTE: If fullscreen causes black screen on external monitor, disable adaptive sync:
  # https://github.com/pop-os/cosmic-epoch/issues/2912

  wayland.desktopManager.cosmic = {
    enable = true;

    appearance.theme.mode = config.theme.polarity;
    appearance.theme.${config.theme.polarity} =
      lib.mkIf (config.theme.cosmic.ronFile != null)
      (importRON config.theme.cosmic.ronFile);

    # Compositor
    compositor = {
      active_hint = true;

      autotile = true;
      autotile_behavior = mkRON "enum" "PerWorkspace";

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

    # Panels
    panels = [
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
          [
            "com.system76.CosmicAppletWorkspaces"
            "com.system76.CosmicAppList"
          ]
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
          # "com.system76.CosmicPanelLauncherButton"
          # "com.system76.CosmicPanelWorkspacesButton"
          # "com.system76.CosmicPanelAppButton"
          "com.system76.CosmicAppList"
          "com.system76.CosmicAppletMinimize"
        ];
        plugins_wings = mkRON "optional" null;
      }
    ];

    applets.app-list.settings = {
      enable_drag_source = true;
      favorites = [
        "firefox"
        "code"
        "com.mitchellh.ghostty"
        "slack"
        "thunderbird"
        "org.telegram.desktop"
        "discord"
        "com.system76.CosmicFiles"
      ];
      filter_top_levels = null;
    };

    # Idle: never suspend or turn off screen (docked).
    # Change via COSMIC Settings when undocked; will reset on next home-manager switch.
    idle = {
      screen_off_time = mkRON "optional" null;
      suspend_on_ac_time = mkRON "optional" null;
      suspend_on_battery_time = mkRON "optional" null;
    };

    # Shortcuts
    shortcuts = [
      {
        key = "Super+Return";
        action = mkRON "enum" {
          variant = "System";
          value = [(mkRON "enum" "Terminal")];
        };
      }
    ];

    systemActions = mkRON "map" [
      {
        key = mkRON "enum" "Terminal";
        value = "ghostty";
      }
    ];
  };
}
