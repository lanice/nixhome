{...}: {
  imports = [../common/syncthing.nix];

  fleet.syncthing.folders = {
    sd = ["sencha"];
    sd-misc = ["sencha"];
    stable-diffusion = ["sencha" "SunsetDragon"];
    photo-share = ["sencha" "SunsetDragon" "longjing"];
  };
}
