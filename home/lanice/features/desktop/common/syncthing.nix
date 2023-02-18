{
  services.syncthing = {
    enable = true;
    extraOptions = ["--no-default-folder"];
    tray = {
      enable = true;
      command = "syncthingtray --wait";
    };
  };
}
