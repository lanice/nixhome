{
  imports = [
    ../../common/mail.nix
    ../../common/publishing.nix

    ./forgejo.nix
    ./mail-archive
    ./netconsole-receiver.nix
  ];
}
