{
  config,
  inputs,
  ...
}: {
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
    resticHtpasswd = {
      file = "${inputs.self}/secrets/resticHtpasswd.age";
      owner = "restic";
      group = "restic";
      mode = "400";
    };

    resticB2Credentials.file = "${inputs.self}/secrets/resticB2Credentials.age";
    resticOffsiteHealthcheckUuid.file = "${inputs.self}/secrets/resticOffsiteHealthcheckUuid.age";
    resticMonthlyHealthcheckUuid.file = "${inputs.self}/secrets/resticMonthlyHealthcheckUuid.age";
    resticBobaTransport.file = "${inputs.self}/secrets/resticBobaTransport.age";

    resticSenchaPassword.file = "${inputs.self}/secrets/resticSenchaPassword.age";
    resticForgejoPassword.file = "${inputs.self}/secrets/resticForgejoPassword.age";
    mailArchiveResticPassword.file = "${inputs.self}/secrets/mailArchiveResticPassword.age";
    resticBobaPassword.file = "${inputs.self}/secrets/resticBobaPassword.age";

    resticOffsiteSenchaPassword.file = "${inputs.self}/secrets/resticOffsiteSenchaPassword.age";
    resticOffsiteForgejoPassword.file = "${inputs.self}/secrets/resticOffsiteForgejoPassword.age";
    resticOffsiteMailArchivePassword.file = "${inputs.self}/secrets/resticOffsiteMailArchivePassword.age";
    resticOffsiteBobaPassword.file = "${inputs.self}/secrets/resticOffsiteBobaPassword.age";
  };
}
