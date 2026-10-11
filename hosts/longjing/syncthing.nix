{...}: {
  imports = [../common/syncthing.nix];

  fleet.syncthing.folders = {
    inkplate-photos = ["boba"];
    paperless = ["sencha" "boba"];
    photo-share = ["sencha" "unstable" "SunsetDragon"];
    projects = ["sencha" "SunsetDragon"];
    s23sync = ["sencha" "S23Ultra"];
  };
}
