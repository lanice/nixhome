{
  inputs,
  config,
  ...
}: let
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
  age.secrets.porkbun.file = "${inputs.self}/secrets/porkbun.age";

  services.nginx = {
    enable = true;
    defaultListenAddresses = [tailscaleIP];

    virtualHosts = {
      "sdnext.lanice.dev" = mkVirtualHost 9000;
      "invoke.lanice.dev" = mkVirtualHost 9001;
      "paperlessx.lanice.dev" = mkVirtualHost 58080;
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
      "sdnext.lanice.dev" = mkAcmeCert;
      "invoke.lanice.dev" = mkAcmeCert;
      "paperlessx.lanice.dev" = mkAcmeCert;
    };
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [80 443];
}
