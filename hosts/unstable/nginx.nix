let
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
      "dash.lanice.dev" = mkVirtualHost 8080;
      "sdnext.lanice.dev" = mkVirtualHost 9000;
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "leanderneiss@gmail.com";
      credentialsFile = "/var/lib/secrets/porkbun.env";
      dnsResolver = "1.1.1.1:53";
      dnsPropagationCheck = true;
    };

    certs = {
      "dash.lanice.dev" = mkAcmeCert;
      "sdnext.lanice.dev" = mkAcmeCert;
    };
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [80 443];
}
