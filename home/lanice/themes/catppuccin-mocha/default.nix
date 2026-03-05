{
  theme = {
    polarity = "dark";
    cosmic.ronFile = ./cosmic-catppuccin-mocha-green+slightlyround.ron;

    catppuccin = {
      enable = true;
      flavor = "mocha";
    };
  };

  programs.vscode.profiles.default = {
    userSettings."workbench.colorTheme" = "Catppuccin Mocha";
    userSettings."workbench.iconTheme" = "catppuccin-mocha";
  };

  programs.ghostty.settings.theme = "Catppuccin Mocha";
}
