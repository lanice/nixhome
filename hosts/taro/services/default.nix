{
  homelab = {
    domain = "lanice.dev";
    tailscaleIP = "100.103.16.7";
  };

  imports = [
    ../../common/publishing.nix

    ./forgejo.nix
  ];
}
