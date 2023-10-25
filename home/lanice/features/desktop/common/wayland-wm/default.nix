{pkgs, ...}: {
  imports = [
    ./mako.nix
    ./swaylock.nix
    ./waybar.nix
    ./wofi.nix
    ./zathura.nix
  ];

  xdg.mimeApps.enable = true;
  home.packages = with pkgs; [
    # grim
    gtk3 # For gtk-launch
    # imv
    # mimeo
    # primary-xwayland
    # pulseaudio
    # slurp
    # waypipe
    # wf-recorder
    # wl-clipboard
    # wl-mirror
    # wl-mirror-pick
    # xdg-utils-spawn-terminal # Patched to open terminal
    # ydotool
  ];

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;
    QT_QPA_PLATFORM = "wayland";
    LIBSEAT_BACKEND = "logind";
  };
}
