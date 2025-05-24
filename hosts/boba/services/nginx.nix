{
  inputs,
  config,
  ...
}: let
  tailscaleIP = "100.124.185.117";

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
      "home.lanice.dev" = mkVirtualHost 8081;
      "paperless.lanice.dev" = mkVirtualHost 58080;
      "chat.lanice.dev" = mkVirtualHost 3080;
      "pdf.lanice.dev" = mkVirtualHost 8090;

      "watch.lanice.dev" = mkVirtualHost 8096;
      "browse.lanice.dev" = mkVirtualHost 5055;
      "music.lanice.dev" = mkVirtualHost 4533;

      "jellyfin.lanice.dev" = mkVirtualHost 8096;
      "jellyseerr.lanice.dev" = mkVirtualHost 5055;
      "sonarr.lanice.dev" = mkVirtualHost 8989;
      "radarr.lanice.dev" = mkVirtualHost 7878;
      "lidarr.lanice.dev" = mkVirtualHost 8686;
      "readarr.lanice.dev" = mkVirtualHost 8787;
      "bazarr.lanice.dev" = mkVirtualHost 6767;
      "prowlarr.lanice.dev" = mkVirtualHost 9696;
      "nzbhydra.lanice.dev" = mkVirtualHost 5076;
      "sabnzbd.lanice.dev" = mkVirtualHost 8080;

      "calibre.lanice.dev" = mkVirtualHost 8083;
      "books.lanice.dev" = mkVirtualHost 8083;
      "cwa-download.lanice.dev" = mkVirtualHost 8084;

      "komga.lanice.dev" = mkVirtualHost 8333;
      "kavita.lanice.dev" = mkVirtualHost 5000;

      "uptime.lanice.dev" = mkVirtualHost 3001;
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
      "home.lanice.dev" = mkAcmeCert;
      "paperless.lanice.dev" = mkAcmeCert;
      "chat.lanice.dev" = mkAcmeCert;
      "pdf.lanice.dev" = mkAcmeCert;

      "watch.lanice.dev" = mkAcmeCert;
      "browse.lanice.dev" = mkAcmeCert;
      "music.lanice.dev" = mkAcmeCert;

      "jellyfin.lanice.dev" = mkAcmeCert;
      "jellyseerr.lanice.dev" = mkAcmeCert;
      "sonarr.lanice.dev" = mkAcmeCert;
      "radarr.lanice.dev" = mkAcmeCert;
      "lidarr.lanice.dev" = mkAcmeCert;
      "readarr.lanice.dev" = mkAcmeCert;
      "bazarr.lanice.dev" = mkAcmeCert;
      "prowlarr.lanice.dev" = mkAcmeCert;
      "nzbhydra.lanice.dev" = mkAcmeCert;
      "sabnzbd.lanice.dev" = mkAcmeCert;

      "calibre.lanice.dev" = mkAcmeCert;
      "books.lanice.dev" = mkAcmeCert;
      "cwa-download.lanice.dev" = mkAcmeCert;

      "komga.lanice.dev" = mkAcmeCert;
      "kavita.lanice.dev" = mkAcmeCert;

      "uptime.lanice.dev" = mkAcmeCert;
    };
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [80 443];
}
