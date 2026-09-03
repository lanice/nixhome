_: let
  baseDir = "/home/syncthing";
  fleet = import ../../fleet.nix;
in {
  services.syncthing = {
    enable = true;
    user = "syncthing";
    group = "syncthing";
    dataDir = baseDir; # Default folder for new synced folders

    overrideDevices = true; # overrides any devices added or deleted through the WebUI
    overrideFolders = true; # overrides any folders added or deleted through the WebUI

    guiAddress = "0.0.0.0:8384";

    settings = {
      devices = {
        sencha.id = fleet.hosts.sencha.syncthingId;
        longjing.id = fleet.hosts.longjing.syncthingId;
        S23Ultra.id = fleet.devices.S23Ultra.syncthingId;
      };

      folders = {
        "paperless" = {
          path = "/home/paperless/consume";
          devices = ["sencha" "S23Ultra" "longjing"];
        };
        "books" = {
          path = "/home/books";
          devices = ["sencha"];
        };
      };
    };
  };
}
