{
  theme = {
    polarity = "dark";
    cosmic.ronFile = ./cosmic-catppuccin-macchiato-green+slightlyround.ron;
    wallpaper = ./sunken-galleon.png;

    catppuccin = {
      enable = true;
      flavor = "macchiato";
    };
  };

  programs.vscode.profiles.default = {
    userSettings."workbench.colorTheme" = "Catppuccin Macchiato";
    userSettings."workbench.iconTheme" = "catppuccin-macchiato";
  };

  programs.ghostty.settings.theme = "Catppuccin Macchiato";
}
