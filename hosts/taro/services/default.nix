{
  imports = [
    ../../common/publishing.nix

    ./forgejo.nix
    ./mail-archive
    ./mail.nix
    ./netconsole-receiver.nix
  ];
}
