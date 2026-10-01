{
  imports = [
    ../../common/mail.nix
    ../../common/publishing.nix

    ./coding
    ./forgejo.nix
    ./mail-archive
    ./netconsole-receiver.nix
  ];
}
