{config, ...}: {
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [config.fontProfiles.monospace.family];
      serif = [config.fontProfiles.serif.family];
      sansSerif = [config.fontProfiles.sansSerif.family];
      emoji = [config.fontProfiles.emoji.family];
    };
  };
}
