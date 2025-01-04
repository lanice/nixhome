{config, ...}: let
  tailscaleIP = "100.89.240.111";

  # Common settings for virtual hosts
  mkVirtualHost = port: {
    enableACME = true;
    forceSSL = true;
    listen = [
      {
        addr = tailscaleIP;
        port = 443;
        ssl = true;
      }
    ];
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      proxyWebsockets = true;
    };
  };

  # Common settings for ACME certs
  mkAcmeCert = {
    dnsProvider = "porkbun";
    webroot = null;
  };
in {
  services.nginx = {
    enable = true;
    defaultListenAddresses = [tailscaleIP];

    virtualHosts = {
      "dash.lanice.dev" = mkVirtualHost 8081;
      "home.lanice.dev" = mkVirtualHost 8081;
      "sdnext.lanice.dev" = mkVirtualHost 9000;
      "invoke.lanice.dev" = mkVirtualHost 9001;
      "paperless.lanice.dev" = mkVirtualHost 58080;

      "jellyfin.lanice.dev" = mkVirtualHost 8096;
      # "jellyseerr.lanice.dev" = mkVirtualHost 5055;
      "sonarr.lanice.dev" = mkVirtualHost 8989;
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "leanderneiss@gmail.com";
      credentialsFile = config.age.secrets.porkbun.path;
      dnsResolver = "1.1.1.1:53";
      dnsPropagationCheck = true;
    };

    certs = {
      "dash.lanice.dev" = mkAcmeCert;
      "home.lanice.dev" = mkAcmeCert;
      "sdnext.lanice.dev" = mkAcmeCert;
      "invoke.lanice.dev" = mkAcmeCert;
      "paperless.lanice.dev" = mkAcmeCert;

      "jellyfin.lanice.dev" = mkAcmeCert;
      # "jellyseerr.lanice.dev" = mkAcmeCert;
      "sonarr.lanice.dev" = mkAcmeCert;
    };
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [80 443];
}
