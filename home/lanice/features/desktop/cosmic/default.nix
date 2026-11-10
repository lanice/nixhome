{
  inputs,
  config,
  lib,
  pkgs,
  cosmicLib,
  ...
}: let
  localPkgs = inputs.self.packages.${pkgs.stdenv.hostPlatform.system};
  mkRON = cosmicLib.cosmic.mkRON;
  importRON = cosmicLib.cosmic.importRON;
  # Applet polls every 60s per output; the 30d cost scan takes ~45 CPU-s.
  # Cache its usage/cost calls (shared across applets via flock), pass the rest through.
  # Cost outlasts the applet's 30s CLI kill: serve stale, refresh detached.
  codexbarCached = pkgs.writeShellApplication {
    name = "codexbar";
    runtimeInputs = [pkgs.coreutils pkgs.util-linux];
    text = ''
      real=${lib.getExe localPkgs.codexbar-cli}
      case "$*" in
        "usage --format json")
          key=usage
          ttl=120
          ;;
        # Per-provider account expansion (applet 0.2+), run every refresh.
        "usage --provider "[a-z0-9-]*" --all-accounts --format json")
          key=usage-$3-accounts
          ttl=120
          ;;
        "cost --format json --days 30")
          key=cost
          ttl=1800
          ;;
        *) exec "$real" "$@" ;;
      esac

      dir=''${XDG_CACHE_HOME:-$HOME/.cache}/codexbar-cached
      out=$dir/$key.json
      bg=''${CODEXBAR_CACHED_BG:-}
      mkdir -p "$dir"
      fresh() { [ -f "$out" ] && (($(date +%s) - $(stat -c %Y "$out") < ttl)); }

      # mv is atomic, so stale reads need no lock. Detached child must not hold the applet's pipes.
      if [ "$key" = cost ] && [ -z "$bg" ] && [ -f "$out" ]; then
        fresh || CODEXBAR_CACHED_BG=1 setsid -f "$0" "$@" </dev/null >/dev/null 2>&1
        exec cat "$out"
      fi

      exec 9>"$dir/$key.lock"
      if [ -n "$bg" ]; then flock -n 9 || exit 0; else flock 9; fi

      if fresh; then
        [ -n "$bg" ] && exit 0
        exec cat "$out"
      fi

      rc=0
      "$real" "$@" >"$out.tmp" || rc=$?
      [ -n "$bg" ] || cat "$out.tmp"
      if ((rc == 0)); then mv "$out.tmp" "$out"; else rm -f "$out.tmp"; fi
      exit "$rc"
    '';
  };
  dockAutohideBehavior = {
    wait_time = 500;
    transition_time = 200;
    handle_size = 2;
    unhide_delay = 200;
  };
  # COSMIC 1.3 moved frosted-glass settings to theme schema v2.
  # cosmic-manager and its bundled cosmic-ctl still build the custom theme as
  # schema v1, so write both the v2 builder inputs and active theme outputs.
  frostedGlassConfig = (pkgs.formats.json {}).generate "cosmic-frosted-glass.json" {
    "$schema" = "https://raw.githubusercontent.com/cosmic-utils/cosmic-ctl/refs/heads/main/schema.json";
    operations =
      lib.concatMap
      (theme:
        map
        (componentSuffix: {
          component = "com.system76.CosmicTheme.${theme}${componentSuffix}";
          xdg_directory = "config";
          version = 2;
          operation = "write";
          entries = {
            frosted = "Medium";
            frosted_applets = "true";
            frosted_panel = "true";
            frosted_system_interface = "true";
            frosted_windows = "true";
          };
        })
        [".Builder" ""])
      ["Dark" "Light"];
  };
in {
  imports = [
    inputs.cosmic-manager.homeManagerModules.cosmic-manager
    ../common
  ];

  options.desktops.cosmic.enable = lib.mkEnableOption "Cosmic desktop user environment";

  config = lib.mkIf config.desktops.cosmic.enable {
    home.packages = [
      # inputs.cosmic-applets-collection.packages.${pkgs.stdenv.hostPlatform.system}.minimon-applet
      # inputs.cosmic-applets-collection.packages.${pkgs.stdenv.hostPlatform.system}.cosmic-ext-applet-clipboard-manager
      localPkgs.cosmic-ext-applet-codexbar
      codexbarCached # CLI the applet shells out to for usage data
    ];

    home.activation.configureCosmicFrostedGlass = lib.hm.dag.entryAfter ["configureCosmic"] ''
      run ${lib.getExe config.programs.cosmic-ext-ctl.package} apply ${frostedGlassConfig}
    '';

    # NOTE: If fullscreen causes black screen on external monitor, disable adaptive sync:
    # https://github.com/pop-os/cosmic-epoch/issues/2912

    wayland.desktopManager.cosmic = {
      enable = true;

      appearance.theme.mode = config.theme.polarity;
      appearance.theme.${config.theme.polarity} =
        lib.mkIf (config.theme.cosmic.ronFile != null)
        (importRON config.theme.cosmic.ronFile);

      wallpapers =
        lib.mkIf (config.theme.wallpaper != null)
        [
          {
            output = "all";
            source = mkRON "enum" {
              variant = "Path";
              value = [config.theme.wallpaper];
            };
            filter_by_theme = false;
            filter_method = mkRON "enum" "Lanczos";
            scaling_mode = mkRON "enum" "Zoom";
            sampling_method = mkRON "enum" "Alphanumeric";
            rotation_frequency = 0;
          }
        ];

      appearance.toolkit.icon_theme = "Papirus";
      appearance.toolkit.apply_theme_global = true;

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
          anchor_gap = true;
          margin = 8;
          border_radius = 16;
          expand_to_edges = true;
          opacity = 0.8;

          size = mkRON "enum" "XS";

          plugins_center = mkRON "optional" [
            "com.system76.CosmicAppletTime"
          ];
          plugins_wings = mkRON "optional" (mkRON "tuple" [
            [
              "com.system76.CosmicAppletWorkspaces"
              "com.system76.CosmicAppList"
              "io.github.cosmic_utils.cosmic-ext-applet-clipboard-manager"
            ]
            [
              # "com.system76.CosmicAppletInputSources"
              "io.github.andrew_verde.cosmic-ext-applet-codexbar"
              # "io.github.cosmic_utils.minimon-applet"
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
          autohide = mkRON "optional" dockAutohideBehavior;
          autohide_behavior = dockAutohideBehavior;
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

      # cosmic-manager still emits COSMIC's pre-1.4 optional autohide value.
      configFile."com.system76.CosmicPanel.Dock".entries.autohide =
        lib.mkForce (mkRON "raw" "OnOverlap");

      applets.app-list.settings = {
        enable_drag_source = true;
        favorites = [
          (
            if config.browser.default == "zen"
            then "zen-beta"
            else "firefox"
          )
          "com.mitchellh.ghostty"
          "slack"
          "thunderbird"
          "org.telegram.desktop"
          "discord"
          "com.system76.CosmicFiles"
        ];
        filter_top_levels = null;
      };

      # Turn off displays after 15 minutes; never suspend.
      idle = {
        screen_off_time = mkRON "optional" 900000;
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
        # Overrides default Focus(Right)
        {
          key = "Super+l";
          action = mkRON "enum" {
            variant = "System";
            value = [(mkRON "enum" "LockScreen")];
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
  };
}
