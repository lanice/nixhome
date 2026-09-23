{
  inputs,
  config,
  ...
}: let
  port = 5000;
in {
  # Serves boba's own /nix/store, so anything built here (e.g. by the
  # forgejo-runner's nix:host jobs) is fetchable fleet-wide. Clients trust the
  # key in hosts/common/global/nix.nix.
  age.secrets.binaryCacheKey.file = "${inputs.self}/secrets/binaryCacheKey.age";

  services.harmonia.cache = {
    enable = true;
    signKeyPaths = [config.age.secrets.binaryCacheKey.path];
    settings.bind = "127.0.0.1:${toString port}";
  };

  # Tailnet-only: harmonia exposes every path in the store, not just CI builds.
  homelab.published.cache.proxyTo = port;
}
