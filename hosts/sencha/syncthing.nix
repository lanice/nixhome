{
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
        "unstable" = {id = "";};
        "Orange Laptop" = {id = "P5ZXGOQ-WYCICPY-3ZS7XKZ-6YKJKUD-U5RXUEA-R64HDVZ-4KHAFNA-CMKZIQN";};
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
          devices = ["unstable" "Orange Laptop"];
        };
        "photo-share" = {
          path = "/home/lanice/Sync/photo-share";
          devices = ["unstable" "Orange Laptop"];
        };
      };
    };
  };
}
