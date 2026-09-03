{pkgs, ...}: {
  services.syncthing = {
    enable = true;
    user = "lanice";
    dataDir = "/home/lanice/Sync"; # Default folder for new synced folders
    configDir = "/home/lanice/.config/syncthing"; # Folder for Syncthing's settings and keys

    overrideDevices = true; # overrides any devices added or deleted through the WebUI
    overrideFolders = true; # overrides any folders added or deleted through the WebUI

    guiAddress = "0.0.0.0:8384";

    settings = {
      devices = {
        "sencha" = {id = "4BN4A3S-EUA2SVD-QNEJHI6-LJKBVWW-7FV4YRE-5YOIQBR-A4CWZLB-OQLGBA6";};
        "boba" = {id = "DGY5HLA-TIKZI6X-BNMZULZ-PHPMCJH-L57RGVV-TGEKYH3-7VISX5L-W4KYOQL";};
        "unstable" = {id = "ZSOKQGJ-K55JPO2-W4N75YJ-6NJI64R-HLQTT72-JENBU3L-DU44IG5-BVHIXAS";};
        "SunsetDragon" = {id = "GQWATA7-Y6EUELT-HZYCAOU-O6AMUID-YIU4AYD-O7QT3V4-ZUE4ZP7-LIITDAE";};
        "S23Ultra" = {id = "IO377ZW-XGOPD22-O6N6B4F-WQJYEYF-2GE463X-DH7MY4M-ZZEQ5CN-T2HJTAC";};
      };

      folders = {
        "paperless" = {
          path = "/home/lanice/Sync/paperless";
          devices = ["sencha" "boba"];
        };
        "photo-share" = {
          path = "/home/lanice/Sync/photo-share";
          devices = ["sencha" "unstable" "SunsetDragon"];
        };
        "projects" = {
          path = "/home/lanice/Sync/projects";
          devices = ["sencha" "SunsetDragon"];
        };
        "s23sync" = {
          path = "/home/lanice/Sync/s23sync";
          devices = ["sencha" "S23Ultra"];
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    syncthingtray
  ];
}
