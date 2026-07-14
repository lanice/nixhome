{
  pkgs,
  lib,
  config,
  ...
}: let
  extensions = import ./list.nix {inherit pkgs lib;};
  mapDconfSettings =
    builtins.map
    (
      e: let
        dconfSlug =
          e.dconfSlug or e.package.extensionPortalSlug;
      in {
        "org/gnome/shell/extensions/${dconfSlug}" = e.dconfSettings;
      }
    )
    extensions;
  recursiveMergeAttrs = lib.foldr lib.recursiveUpdate {};
in {
  config = lib.mkIf config.desktops.gnome.enable {
    home.packages = with pkgs;
      builtins.map (e: e.package) extensions;

    # Use dconf watch / to record changes
    # Use dconf2nix to get an idea of how to format the changes
    dconf.settings =
      {
        "org/gnome/shell" = {
          disable-user-extensions = false;

          disabled-extensions = [];

          # `gnome-extensions list` for a list
          enabled-extensions = let
            enabled = builtins.filter (e: !(e.disable or false)) extensions;
          in
            builtins.map (e: e.package.extensionUuid) enabled;
        };
      }
      // recursiveMergeAttrs mapDconfSettings;
  };
}
