{config, ...}: {
  programs.ghostty = {
    enable = true;
    settings = {
      theme = "Gruvbox Material";
      # theme = "Monokai Remastered";

      cursor-style = "bar";
      cursor-style-blink = false;
      shell-integration-features = "no-cursor";

      quit-after-last-window-closed = false;

      window-height = 48;
      window-width = 160;
      window-inherit-working-directory = false;

      window-decoration = "server";

      gtk-single-instance = true;

      font-family = config.fontProfiles.monospace.family;
    };
  };
}
