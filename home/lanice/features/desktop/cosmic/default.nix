{...}: {
  imports = [
    ../common
  ];

  services.xsettingsd.enable = false;

  # COSMIC config (RON format)
  # Managed declaratively — GUI changes won't persist across home-manager switch
  xdg.configFile."cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom".text = ''
    {
        (modifiers: [Super], key: "Return"): System(Terminal),
    }
  '';
  xdg.configFile."cosmic/com.system76.CosmicSettings.Shortcuts/v1/system_actions".text = ''
    {
        Terminal: "ghostty",
    }
  '';

  # NOTE: If fullscreen causes black screen on external monitor, disable adaptive sync:
  # https://github.com/pop-os/cosmic-epoch/issues/2912
}
