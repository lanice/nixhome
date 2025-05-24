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
        "boba" = {id = "DGY5HLA-TIKZI6X-BNMZULZ-PHPMCJH-L57RGVV-TGEKYH3-7VISX5L-W4KYOQL";};
        "unstable" = {id = "ZSOKQGJ-K55JPO2-W4N75YJ-6NJI64R-HLQTT72-JENBU3L-DU44IG5-BVHIXAS";};
        "SunsetDragon" = {id = "GQWATA7-Y6EUELT-HZYCAOU-O6AMUID-YIU4AYD-O7QT3V4-ZUE4ZP7-LIITDAE";};
        "S23Ultra" = {id = "IO377ZW-XGOPD22-O6N6B4F-WQJYEYF-2GE463X-DH7MY4M-ZZEQ5CN-T2HJTAC";};
      };

      folders = {
        "sd" = {
          path = "/home/lanice/Sync/sd";
          devices = ["unstable"];
        };
        "sd-misc" = {
          path = "/home/lanice/Sync/sd-misc";
          devices = ["unstable"];
        };
        "paperless" = {
          path = "/home/lanice/Sync/paperless";
          devices = ["boba"];
        };
        "books" = {
          path = "/home/lanice/Sync/books";
          devices = ["boba"];
        };
        "stable-diffusion" = {
          path = "/home/lanice/Sync/stable-diffusion";
          devices = ["unstable" "SunsetDragon"];
        };
        "photo-share" = {
          path = "/home/lanice/Sync/photo-share";
          devices = ["unstable" "SunsetDragon"];
        };
        "projects" = {
          path = "/home/lanice/Sync/projects";
          devices = ["SunsetDragon"];
        };
        "s23sync" = {
          path = "/home/lanice/Sync/s23sync";
          devices = ["S23Ultra"];
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    syncthingtray
  ];
}
