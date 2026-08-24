{
  config,
  inputs,
  ...
}: let
  resticOwnedSecret = file: {
    inherit file;
    owner = "restic";
    group = "restic";
    mode = "0400";
  };
in {
  # Match services.restic.server's account so ticket 03 can enable the service
  # without changing secret ownership or the landing directory identity.
  users.users.restic = {
    group = "restic";
    home = "/data/backups/restic";
    createHome = true;
    uid = config.ids.uids.restic;
  };
  users.groups.restic.gid = config.ids.uids.restic;

  age.secrets = {
    resticHtpasswd = resticOwnedSecret "${inputs.self}/secrets/resticHtpasswd.age";

    resticB2Credentials = resticOwnedSecret "${inputs.self}/secrets/resticB2Credentials.age";
    resticOffsiteHealthcheckUuid = resticOwnedSecret "${inputs.self}/secrets/resticOffsiteHealthcheckUuid.age";
    resticMonthlyHealthcheckUuid = resticOwnedSecret "${inputs.self}/secrets/resticMonthlyHealthcheckUuid.age";
    resticBobaTransport.file = "${inputs.self}/secrets/resticBobaTransport.age";

    resticSenchaPassword = resticOwnedSecret "${inputs.self}/secrets/resticSenchaPassword.age";
    resticForgejoPassword = resticOwnedSecret "${inputs.self}/secrets/resticForgejoPassword.age";
    mailArchiveResticPassword = resticOwnedSecret "${inputs.self}/secrets/mailArchiveResticPassword.age";
    resticBobaPassword = resticOwnedSecret "${inputs.self}/secrets/resticBobaPassword.age";

    resticOffsiteSenchaPassword = resticOwnedSecret "${inputs.self}/secrets/resticOffsiteSenchaPassword.age";
    resticOffsiteForgejoPassword = resticOwnedSecret "${inputs.self}/secrets/resticOffsiteForgejoPassword.age";
    resticOffsiteMailArchivePassword = resticOwnedSecret "${inputs.self}/secrets/resticOffsiteMailArchivePassword.age";
    resticOffsiteBobaPassword = resticOwnedSecret "${inputs.self}/secrets/resticOffsiteBobaPassword.age";
  };
}
