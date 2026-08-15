# Nightly restic backup of the archive to boba (spec § Backup). Versioned on
# purpose: an unversioned mirror would replicate archive corruption to boba the
# same night. No timer — the nightly chain starts it.
{
  inputs,
  config,
  ...
}: let
  boba = (import ../../fleet.nix).hosts.boba;
in {
  age.secrets.mailArchiveResticPassword.file = "${inputs.self}/secrets/mailArchiveResticPassword.age";
  age.secrets.mailArchiveBackupKey.file = "${inputs.self}/secrets/mailArchiveBackupKey.age";

  services.restic.backups.mail-archive = {
    repository = "sftp:mail-archive-backup@${boba.tailscaleIP}:/data/storage/mail-archive-backup";
    # Whole store, no excludes: uidlist/uidvalidity aren't cleanly rebuildable,
    # ACL files should ride along, index churn dedups away.
    paths = ["/var/lib/mail-archive"];
    passwordFile = config.age.secrets.mailArchiveResticPassword.path;
    initialize = true;
    extraOptions = [
      "sftp.command='ssh mail-archive-backup@${boba.tailscaleIP} -i ${config.age.secrets.mailArchiveBackupKey.path} -s sftp'"
    ];
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 12"
    ];
    timerConfig = null;
  };

  systemd.services.restic-backups-mail-archive.unitConfig.OnFailure = "notify-failure@%n.service";
}
