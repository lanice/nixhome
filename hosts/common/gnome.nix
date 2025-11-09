{pkgs, ...}: {
  services.xserver = {
    enable = true;

    xkb = {
      layout = "us";
      variant = "intl";
      # variant = "";
    };
  };

  services.desktopManager.gnome.enable = true;

  services.displayManager = {
    gdm.enable = true;
    gdm.autoSuspend = false;
    gdm.wayland = true;
  };

  environment = {
    gnome.excludePackages = with pkgs; [
      gnome-photos
      gnome-tour
      gnome-console
      cheese # webcam tool
      epiphany # web browser
      geary # email reader
      yelp # Help view
      gnome-maps
      gnome-music
      # gedit # text editor
      gnome-characters
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
      gnome-contacts
      gnome-initial-setup

      gnome-shell-extensions # Superseded by gnome-extension-manager, not actually doing anything
      gnome-software # Software store, useless in NixOS
    ];

    systemPackages = with pkgs; [
      gnome-tweaks
      dconf-editor
      dconf2nix
    ];
  };

  services.udev.packages = with pkgs; [gnome-settings-daemon];
}
