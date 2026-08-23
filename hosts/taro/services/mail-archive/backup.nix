# Nightly restic backup of the archive to boba (spec § Backup). Versioned on
# purpose: an unversioned mirror would replicate archive corruption to boba the
# same night. No timer — the nightly chain starts it.
{
  inputs,
  config,
  ...
}: let
  boba = (import ../../../fleet.nix).hosts.boba;
in {
  age.secrets.mailArchiveResticPassword.file = "${inputs.self}/secrets/mailArchiveResticPassword.age";

  services.restic.backups.mail-archive = {
    repository = "rest:http://${boba.tailscaleIP}:8000/mail-archive";
    environmentFile = config.age.secrets.resticMailArchiveTransport.path;
    # Whole store, no excludes: uidlist/uidvalidity aren't cleanly rebuildable,
    # ACL files should ride along, index churn dedups away. Host keys include
    # taro's agenix identity.
    paths = [
      "/var/lib/mail-archive"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
    passwordFile = config.age.secrets.mailArchiveResticPassword.path;
    # The repository was migrated from boba's old SFTP landing. Never turn
    # this on: a bad URL must fail rather than create an empty repository.
    initialize = false;
    extraBackupArgs = ["--retry-lock=1h"];
    timerConfig = null;
  };

  systemd.services.restic-backups-mail-archive.unitConfig.OnFailure = "notify-failure@%n.service";
}
