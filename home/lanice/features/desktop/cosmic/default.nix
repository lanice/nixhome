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

  xdg.configFile."cosmic/com.system76.CosmicComp/v1/xkb_config".text = ''
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

  # NOTE: If fullscreen causes black screen on external monitor, disable adaptive sync:
  # https://github.com/pop-os/cosmic-epoch/issues/2912
}
