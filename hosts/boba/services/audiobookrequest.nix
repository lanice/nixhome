{config, ...}: let
  media = config.homelab.media;
  configDir = "/var/lib/audiobookrequest";
in {
  systemd.tmpfiles.rules = [
    "d ${configDir} 0770 ${media.owner} ${media.group} - -"
  ];

  virtualisation.oci-containers.containers = {
    audiobookrequest = {
      image = "markbeep/audiobookrequest:latest";
      ports = ["${toString config.homelab.published.audiobookrequest.proxyTo}:8000"];
      autoStart = true;
      environment = {
        "PUID" = toString media.uid;
        "PGID" = toString media.gid;
        "TZ" = "America/New_York";
      };
      volumes = [
        "${configDir}:/config:rw"
      ];
    };
  };

  homelab.published.audiobookrequest.proxyTo = 8799;
}
