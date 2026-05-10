{
  inputs,
  config,
  tailscaleIP,
  ...
}: let
  domain = "peertube.lanice.dev";
  bulkDir = "/data/storage/peertube";
in {
  age.secrets.peertube-secrets = {
    file = "${inputs.self}/secrets/peertube-secrets.age";
    owner = "peertube";
    group = "peertube";
    mode = "400";
  };

  age.secrets.peertube-db-password = {
    file = "${inputs.self}/secrets/peertube-db-password.age";
    owner = "peertube";
    group = "peertube";
    mode = "400";
  };

  systemd.tmpfiles.rules = [
    "d ${bulkDir} 0750 peertube peertube - -"
    "d ${bulkDir}/web-videos 0750 peertube peertube - -"
    "d ${bulkDir}/streaming-playlists 0750 peertube peertube - -"
    "d ${bulkDir}/original-video-files 0750 peertube peertube - -"
    "d ${bulkDir}/redundancy 0750 peertube peertube - -"
  ];

  services.peertube = {
    enable = true;
    localDomain = domain;
    enableWebHttps = true;
    listenWeb = 443;
    listenHttp = 9000;

    secrets.secretsFile = config.age.secrets.peertube-secrets.path;

    database = {
      createLocally = true;
      passwordFile = config.age.secrets.peertube-db-password.path;
    };

    redis.createLocally = true;

    dataDirs = [bulkDir];

    settings.storage = {
      web_videos = "${bulkDir}/web-videos/";
      streaming_playlists = "${bulkDir}/streaming-playlists/";
      original_video_files = "${bulkDir}/original-video-files/";
      redundancy = "${bulkDir}/redundancy/";
    };

    configureNginx = true;
  };

  # Override the auto-generated vhost to listen on the Tailscale IP, matching
  # the pattern used by every other vhost on boba.
  services.nginx.virtualHosts.${domain} = {
    enableACME = true;
    forceSSL = true;
    listen = [
      {
        addr = tailscaleIP;
        port = 443;
        ssl = true;
      }
    ];
  };

  security.acme.certs.${domain} = {
    dnsProvider = "porkbun";
    webroot = null;
  };
}
