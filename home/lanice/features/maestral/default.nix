{pkgs, ...}: {
  imports = [
    ./daemon
  ];

  home.packages = [pkgs.maestral-gui];

  home.file.".config/autostart/maestral-gui.desktop".text = ''
    [Desktop Entry]
    Name=Maestral GUI
    Exec=${pkgs.maestral-gui}/bin/maestral_qt
    Comment=Tray application for Maestral
    Type=Application
    Terminal=false
    X-GNOME-Autostart-Delay=0
    X-GNOME-Autostart-enabled=true
  '';
}
