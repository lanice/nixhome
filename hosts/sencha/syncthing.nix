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
        "unstable" = {id = "ZSOKQGJ-K55JPO2-W4N75YJ-6NJI64R-HLQTT72-JENBU3L-DU44IG5-BVHIXAS";};
        "Orange Laptop" = {id = "P5ZXGOQ-WYCICPY-3ZS7XKZ-6YKJKUD-U5RXUEA-R64HDVZ-4KHAFNA-CMKZIQN";};
        "SunsetDragon" = {id = "GQWATA7-Y6EUELT-HZYCAOU-O6AMUID-YIU4AYD-O7QT3V4-ZUE4ZP7-LIITDAE";};
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
        "models" = {
          path = "/home/lanice/Sync/models";
          devices = ["unstable"];
        };
        "stable-diffusion" = {
          path = "/home/lanice/Sync/stable-diffusion";
          devices = ["unstable" "Orange Laptop" "SunsetDragon"];
        };
        "photo-share" = {
          path = "/home/lanice/Sync/photo-share";
          devices = ["unstable" "Orange Laptop" "SunsetDragon"];
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    syncthingtray
  ];
}
