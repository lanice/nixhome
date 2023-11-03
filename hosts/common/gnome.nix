{pkgs, ...}: {
  services.xserver = {
    enable = true;

    desktopManager.gnome.enable = true;

    displayManager = {
      gdm.enable = true;
      gdm.autoSuspend = false;
      gdm.wayland = false;
    };

    layout = "us";
    xkbVariant = "intl";
    # xkbVariant = "";
  };

  environment = {
    enableAllTerminfo = true;
    gnome.excludePackages =
      (with pkgs; [
        gnome-photos
        gnome-tour
      ])
      ++ (with pkgs.gnome; [
        cheese # webcam tool
        gnome-music
        gedit # text editor
        epiphany # web browser
        geary # email reader
        gnome-characters
        tali # poker game
        iagno # go game
        hitori # sudoku game
        atomix # puzzle game
        yelp # Help view
        gnome-contacts
        gnome-initial-setup
      ]);

    systemPackages = with pkgs; [
      gnome.gnome-tweaks
    ];
  };

  services.udev.packages = with pkgs; [gnome.gnome-settings-daemon];
}
