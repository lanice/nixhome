{
  imports = [
    ../../common/mail.nix
    ../../common/publishing.nix

    ./coding
    ./forgejo.nix
    ./mail-archive
    ./herdr.nix
    ./netconsole-receiver.nix
    ./t3code
  ];
}
