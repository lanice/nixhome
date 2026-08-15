# Landing area for taro's nightly mail-archive restic repo (sender in
# hosts/taro/services/mail-archive-backup.nix).
_: {
  users.users.mail-archive-backup = {
    isSystemUser = true;
    group = "mail-archive-backup";
    home = "/data/storage/mail-archive-backup";
    openssh.authorizedKeys.keys = [
      "restrict,command=\"internal-sftp\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJLln2Y/4Ts2cHrGGRrK3eEBkizDImmOjpDOrMQ9mB1O mail-archive-backup@taro"
    ];
  };
  users.groups.mail-archive-backup = {};

  systemd.tmpfiles.rules = [
    "d /data/storage/mail-archive-backup 0750 mail-archive-backup mail-archive-backup -"
  ];
}
