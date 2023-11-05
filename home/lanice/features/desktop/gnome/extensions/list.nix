{
  pkgs,
  lib,
  ...
}: let
  inherit (lib.hm.gvariant) mkTuple;
in
  with pkgs.gnomeExtensions; [
    {
      package = app-icons-taskbar;
      dconfSlug = "aztaskbar";
      dconfSettings = {
        position-in-panel = "LEFT";
        position-offset = 2;
        panel-location = "TOP";

        main-panel-height = mkTuple [true 52];
        icon-size = 40;

        indicator-location = "TOP";

        isolate-workspaces = false;
        isolate-monitors = false;

        unity-badges = false;
        notification-badges = false;

        show-panel-activities-button = false;
        show-apps-button = mkTuple [true 0];

        window-previews-show-timeout = 0;
        window-previews-hide-timeout = 0;
      };
    }

    {
      package = space-bar;
      dconfSettings = {};
    }

    {
      package = tophat;
      dconfSettings = {};
    }

    {
      package = appindicator;
      dconfSettings = {};
    }

    {
      package = openweather;
      dconfSettings = {};
    }

    # {
    #   package = media-controls;
    #   dconfSettings = {};
    # }

    {
      package = caffeine;
      dconfSettings = {
        show-indicator = "always";
      };
    }

    {
      package = pano;
      dconfSettings = {
        # Remove audio and notification cues on copy
        send-notification-on-copy = false;
        play-audio-on-copy = false;

        # Do not generate link previews for copied links
        link-previews = false;

        # Window title(?) based excludes
        exclusion-list = ["Bitwarden" "1Password" "KeePassXC" "secrets" "org.gnome.World.Secrets" "Tor Browser"];
      };
    }

    {
      package = removable-drive-menu;
      dconfSettings = {};
    }

    {
      package = quick-settings-audio-panel;
      dconfSettings = {};
    }

    # {
    #   package = gsconnect;
    #   dconfSettings = {
    #     panel-position = "top";
    #   };
    # }
  ]
