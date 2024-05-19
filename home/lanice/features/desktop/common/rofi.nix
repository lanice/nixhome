{
  config,
  lib,
  ...
}: {
  programs.rofi = {
    enable = true;

    font = lib.mkForce "${config.fontProfiles.monospace.family} 12";
    terminal = "alacritty";
    location = "center";

    extraConfig = {
      modi = "run,drun,window";
      icon-theme = "Oranchelo";
      show-icons = true;
      drun-display-format = "{icon} {name}";
      disable-history = false;
      hide-scrollbar = true;
      display-drun = "   Apps ";
      display-run = "   Run ";
      display-window = "   Window";
      display-Network = " 󰤨  Network";
      sidebar-mode = true;
    };
  };
}
