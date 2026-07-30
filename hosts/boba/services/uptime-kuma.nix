{
  config,
  lib,
  ...
}: {
  services.uptime-kuma = {
    enable = true;
    settings = {
      PORT = "3001";
    };
  };

  homelab.published.uptime-kuma = {
    subdomain = "uptime";
    # settings are environment variables, so PORT is a string here.
    proxyTo = lib.toInt config.services.uptime-kuma.settings.PORT;
  };
}
