{
  theme = {
    polarity = "light";
    cosmic.ronFile = ./cosmic-catppuccin-latte-green+slightlyround.ron;
    wallpaper = ./sleeping-cat.png;

    catppuccin = {
      enable = true;
      flavor = "latte";
    };
  };

  programs.vscode.profiles.default = {
    userSettings."workbench.colorTheme" = "Catppuccin Latte";
    userSettings."workbench.iconTheme" = "catppuccin-latte";
  };

  programs.ghostty.settings.theme = "Catppuccin Latte";
}
