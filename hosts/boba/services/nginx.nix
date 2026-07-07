{
  inputs,
  config,
  tailscaleIP,
  ...
}: let
  # Common settings for virtual hosts
  mkVirtualHost = port: {
    enableACME = true;
    forceSSL = true;
    # Explicit listen on both 443 (TLS) and 80. With forceSSL the module emits
    # a redirect server block on the plain-HTTP port; without a non-SSL listen
    # entry nothing listens on :80 and http:// URLs are refused. ACME uses
    # DNS-01 (porkbun), so no HTTP-01 challenge competes for port 80.
    listen = [
      {
        addr = tailscaleIP;
        port = 443;
        ssl = true;
      }
      {
        addr = tailscaleIP;
        port = 80;
        ssl = false;
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

  # nginx binds exclusively to the Tailscale IP (tailscaleIP). On a cold boot
  # nginx can start before tailscaled has assigned that CGNAT address to
  # tailscale0, so bind() fails with EADDRNOTAVAIL and systemd gives up after
  # hitting the restart limit — leaving nginx dead until a manual restart.
  # Allowing non-local binds lets nginx listen on the address before it exists;
  # the socket goes live once Tailscale brings the interface up.
  boot.kernel.sysctl."net.ipv4.ip_nonlocal_bind" = 1;

  services.nginx = {
    enable = true;
    defaultListenAddresses = [tailscaleIP];

    recommendedBrotliSettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    commonHttpConfig = ''
      access_log syslog:server=unix:/dev/log;
      # Silences the "could not build optimal proxy_headers_hash" warning that
      # recommendedProxySettings + many vhosts trigger at the default bucket size.
      proxy_headers_hash_bucket_size 128;
    '';

    virtualHosts = {
      "home.lanice.dev" = mkVirtualHost 8081;
      "paperless.lanice.dev" = mkVirtualHost 58080;
      "chat.lanice.dev" = mkVirtualHost 3080;
      "pdf.lanice.dev" = mkVirtualHost 8090;

      "watch.lanice.dev" = mkVirtualHost 8096;
      "browse.lanice.dev" = mkVirtualHost 5055;
      "music.lanice.dev" = mkVirtualHost 4533;
      "audiobookshelf.lanice.dev" = mkVirtualHost 8588;

      "jellyfin.lanice.dev" = mkVirtualHost 8096;
      "jellyseerr.lanice.dev" = mkVirtualHost 5055;
      "sonarr.lanice.dev" = mkVirtualHost 8989;
      "radarr.lanice.dev" = mkVirtualHost 7878;
      "lidarr.lanice.dev" = mkVirtualHost 8686;
      "lidarr-old.lanice.dev" = mkVirtualHost 8687;
      "bookshelf.lanice.dev" = mkVirtualHost 8787;
      "bazarr.lanice.dev" = mkVirtualHost 6767;
      "prowlarr.lanice.dev" = mkVirtualHost 9696;
      "nzbhydra.lanice.dev" = mkVirtualHost 5076;
      "sabnzbd.lanice.dev" = mkVirtualHost 8080;
      "slskd.lanice.dev" = mkVirtualHost 5030;

      "audiobookrequest.lanice.dev" = mkVirtualHost 8799;
      "aurral.lanice.dev" = mkVirtualHost 3002;
      "explo.lanice.dev" = mkVirtualHost 7288;

      "scrutiny.lanice.dev" = mkVirtualHost 8082;
      "uptime.lanice.dev" = mkVirtualHost 3001;
      "adguard.lanice.dev" = mkVirtualHost 3003;
      "tracearr.lanice.dev" = mkVirtualHost 3000;
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "leanderneiss@gmail.com";
      environmentFile = config.age.secrets.porkbun.path;
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
      "audiobookshelf.lanice.dev" = mkAcmeCert;

      "jellyfin.lanice.dev" = mkAcmeCert;
      "jellyseerr.lanice.dev" = mkAcmeCert;
      "sonarr.lanice.dev" = mkAcmeCert;
      "radarr.lanice.dev" = mkAcmeCert;
      "lidarr.lanice.dev" = mkAcmeCert;
      "lidarr-old.lanice.dev" = mkAcmeCert;
      "bookshelf.lanice.dev" = mkAcmeCert;
      "bazarr.lanice.dev" = mkAcmeCert;
      "prowlarr.lanice.dev" = mkAcmeCert;
      "nzbhydra.lanice.dev" = mkAcmeCert;
      "sabnzbd.lanice.dev" = mkAcmeCert;
      "slskd.lanice.dev" = mkAcmeCert;

      "audiobookrequest.lanice.dev" = mkAcmeCert;
      "aurral.lanice.dev" = mkAcmeCert;
      "explo.lanice.dev" = mkAcmeCert;

      "scrutiny.lanice.dev" = mkAcmeCert;
      "uptime.lanice.dev" = mkAcmeCert;
      "adguard.lanice.dev" = mkAcmeCert;
      "tracearr.lanice.dev" = mkAcmeCert;
    };
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [80 443];
}
