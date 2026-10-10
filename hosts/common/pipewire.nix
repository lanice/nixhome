_: {
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    # media-session.enable = true;

    wireplumber.enable = true;

    # A2DP can connect after HFP (bluetoothd EBUSY race); with autoswitch on, WirePlumber
    # ignores the late profile, leaving the headset on HFP. Re-select shortly after connect.
    wireplumber.extraScripts."device/bt-late-a2dp.lua" = ''
      cutils = require ("common-utils")
      log = Log.open_topic ("s-device")

      local WINDOW_USEC = 20 * 1000000
      local added_at = {}

      SimpleEventHook {
        name = "custom/bt-late-a2dp-added",
        interests = { EventInterest { Constraint { "event.type", "=", "device-added" } } },
        execute = function (event)
          local device = event:get_subject ()
          if device.properties ["device.api"] == "bluez5" then
            added_at [device.id] = GLib.get_monotonic_time ()
          end
        end
      }:register ()

      SimpleEventHook {
        name = "custom/bt-late-a2dp-reselect",
        interests = {
          EventInterest {
            Constraint { "event.type", "=", "device-params-changed" },
            Constraint { "event.subject.param-id", "=", "EnumProfile" },
          },
        },
        execute = function (event)
          local device = event:get_subject ()
          local t = added_at [device.id]
          if not t or GLib.get_monotonic_time () - t > WINDOW_USEC then
            return
          end
          for p in device:iterate_params ("Profile") do
            local profile = cutils.parseParam (p, "Profile")
            local name = profile and profile.name or ""
            if name:find ("^headset%-head%-unit") then
              log:warning (device, "A2DP arrived late, re-selecting profile (was " .. name .. ")")
              event:get_source ():call ("push-event", "select-profile", device, nil)
            end
          end
        end
      }:register ()
    '';
    wireplumber.extraConfig."90-bt-late-a2dp" = {
      "wireplumber.components" = [
        {
          name = "device/bt-late-a2dp.lua";
          type = "script/lua";
          provides = "custom.bt-late-a2dp";
        }
      ];
      "wireplumber.profiles".main."custom.bt-late-a2dp" = "required";
    };
  };
}
