{pkgs, ...}: let
  baseDir = "/home/syncthing";
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
        "sencha" = {id = "4BN4A3S-EUA2SVD-QNEJHI6-LJKBVWW-7FV4YRE-5YOIQBR-A4CWZLB-OQLGBA6";};
        "S23Ultra" = {id = "IO377ZW-XGOPD22-O6N6B4F-WQJYEYF-2GE463X-DH7MY4M-ZZEQ5CN-T2HJTAC";};
      };

      folders = {
        "paperless" = {
          path = "/home/paperless/consume";
          devices = ["sencha" "S23Ultra"];
        };
        "books" = {
          path = "/home/books";
          devices = ["sencha"];
        };
      };
    };
  };
}
