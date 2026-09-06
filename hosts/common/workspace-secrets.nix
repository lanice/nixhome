{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.fleet.workspaceSecrets;
  host = lib.strings.toSentenceCase config.networking.hostName;
in {
  options.fleet.workspaceSecrets.account = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    example = "lanice";
    description = "Account receiving the reusable workspace age identity; null disables provisioning.";
  };

  config = lib.mkIf (cfg.account != null) {
    assertions = [
      {
        assertion = config.users.users ? ${cfg.account};
        message = "fleet.workspaceSecrets.account must name an existing account.";
      }
      {
        assertion = pkgs.secretspec.version == "0.20.0";
        message = "Workspace secrets require SecretSpec 0.20.0; review the runtime contract before upgrading.";
      }
    ];

    age.secrets.workspace-age-identity = {
      file = "${inputs.self}/secrets/workspaceAge${host}.age";
      path = "/run/agenix/workspace-age-identity";
      owner = cfg.account;
      mode = "0400";
    };

    environment.systemPackages = [pkgs.age pkgs.secretspec];
  };
}
