{config, ...}: {
  programs.ghostty = {
    enable = true;
    settings = {
      theme = "Monokai Remastered";

      cursor-style = "bar";
      cursor-style-blink = false;
      shell-integration-features = "no-cursor";

      window-height = 48;
      window-width = 160;
      window-inherit-working-directory = false;

      font-family = config.fontProfiles.monospace.family;
    };
  };
}
