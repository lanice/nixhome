{pkgs, ...}: {
  imports = [./matches];

  services.espanso = {
    enable = true;
    package = pkgs.espanso-wayland;
  };
}
