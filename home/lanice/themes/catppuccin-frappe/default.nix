{
  theme = {
    polarity = "dark";
    cosmic.ronFile = ./cosmic-catppuccin-frappe-green+slightlyround.ron;
    wallpaper = ./spirit-fox.png;

    catppuccin = {
      enable = true;
      flavor = "frappe";
    };
  };

  programs.vscode.profiles.default = {
    userSettings."workbench.colorTheme" = "Catppuccin Frappé";
    userSettings."workbench.iconTheme" = "catppuccin-frappe";
  };

  programs.ghostty.settings.theme = "Catppuccin Frappe";
}
