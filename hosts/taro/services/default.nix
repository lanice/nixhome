{
  imports = [
    ../../common/publishing.nix

    ./forgejo.nix
    ./mail-archive-backup.nix
    ./mail-archive-mirror.nix
    ./mail-archive-nightly.nix
    ./mail-archive-web.nix
    ./mail-archive.nix
    ./mail.nix
    ./netconsole-receiver.nix
  ];
}
