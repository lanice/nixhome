{
  homelab.domain = "lanice.dev";

  imports = [
    ../../common/publishing.nix

    ./forgejo.nix
  ];
}
