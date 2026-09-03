# Syncthing for a workstation: runs as lanice, syncs under ~/Sync, and knows
# its peers by name from the fleet registry. A host declares only which
# folders it takes part in and with whom; paths and device IDs follow.
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.fleet.syncthing;

  fleet = import ../fleet.nix;

  # A literal name: the syncthing module defines users.users from it, so
  # reading the user record back into services.syncthing.user would recurse.
  userName = "lanice";
  user = config.users.users.${userName};
  syncDir = "${user.home}/Sync";

  # Every Syncthing identity the registry knows, fleet hosts and outside
  # devices alike, keyed by the name folders refer to.
  registry =
    lib.mapAttrs (_: d: d.syncthingId)
    (lib.filterAttrs (_: d: d ? syncthingId) (fleet.hosts // fleet.devices));

  peers = lib.unique (lib.concatLists (lib.attrValues cfg.folders));
  unknown = lib.filter (p: !(registry ? ${p})) peers;
in {
  options.fleet.syncthing.folders = lib.mkOption {
    type = lib.types.attrsOf (lib.types.listOf lib.types.str);
    default = {};
    example = {paperless = ["sencha" "boba"];};
    description = ''
      Folders this host syncs, as folder name to the registry names of the
      peers it shares the folder with. Each folder lives at ~/Sync/<name>.
    '';
  };

  config = lib.mkIf (cfg.folders != {}) {
    assertions = [
      {
        assertion = unknown == [];
        message = "fleet.syncthing.folders names peers missing from hosts/fleet.nix: ${lib.concatStringsSep ", " unknown}";
      }
      {
        assertion = !(lib.elem config.networking.hostName peers);
        message = "fleet.syncthing.folders on ${config.networking.hostName} lists the host itself as a peer";
      }
    ];

    services.syncthing = {
      enable = true;
      user = userName;
      dataDir = syncDir; # Default folder for new synced folders
      configDir = "${user.home}/.config/syncthing"; # Folder for Syncthing's settings and keys

      overrideDevices = true; # overrides any devices added or deleted through the WebUI
      overrideFolders = true; # overrides any folders added or deleted through the WebUI

      guiAddress = "0.0.0.0:8384";

      settings = {
        devices = lib.genAttrs peers (name: {id = registry.${name};});
        folders =
          lib.mapAttrs (name: devices: {
            path = "${syncDir}/${name}";
            inherit devices;
          })
          cfg.folders;
      };
    };

    # The syncthing module leaves dataDir alone when the user already exists.
    systemd.tmpfiles.rules = ["d ${syncDir} 0755 ${user.name} ${user.group} -"];

    environment.systemPackages = [pkgs.syncthingtray];
  };
}
