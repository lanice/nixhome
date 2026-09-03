{...}: {
  imports = [../common/syncthing.nix];

  fleet.syncthing.folders = {
    sd = ["unstable"];
    sd-misc = ["unstable"];
    paperless = ["boba" "longjing"];
    books = ["boba"];
    stable-diffusion = ["unstable" "SunsetDragon"];
    photo-share = ["unstable" "SunsetDragon" "longjing"];
    projects = ["SunsetDragon" "longjing"];
    s23sync = ["S23Ultra" "longjing"];
  };
}
