{
  config,
  lib,
  ...
}: let
  cfg = config.homelab.backup;
  dataDir = "/data/backups/restic";
  port = 8000;
  # rest-server 0.14.0 applies this quota to the whole --path, not each repo.
  maxSizeBytes = 320 * 1024 * 1024 * 1024;
in {
  options.homelab.backup.landingRepos = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [];
    description = "Landing repository names created locally and processed by the offsite chain.";
  };

  config = {
    # This is the single declaration point for landing directories and for the
    # offsite copy/prune chain added in ticket 08.
    homelab.backup.landingRepos = [
      "sencha"
      "forgejo"
      "mail-archive"
      "boba"
    ];

    services.restic.server = {
      enable = true;
      inherit dataDir;
      listenAddress = toString port;
      appendOnly = true;
      privateRepos = true;
      htpasswd-file = config.age.secrets.resticHtpasswd.path;
      extraFlags = [
        "--max-size"
        (toString maxSizeBytes)
      ];
    };

    systemd.services.restic-rest-server = {
      after = ["zfs-mount.service"];
      requires = ["zfs-mount.service"];
    };

    systemd.tmpfiles.rules =
      map (
        name: "d ${dataDir}/${name} 0700 restic restic -"
      )
      cfg.landingRepos;

    networking.firewall.interfaces = {
      tailscale0.allowedTCPPorts = [port];
      lo.allowedTCPPorts = [port];
    };
  };
}
