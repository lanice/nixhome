{config, ...}: let
  media = config.homelab.media;
  dataDir = "/var/lib/maintainerr";
in {
  systemd.tmpfiles.rules = [
    "d ${dataDir} 0750 ${media.owner} ${media.group} - -"
  ];

  # Review-only: rule groups carry an *arr action but no "take action after days",
  # so nothing is removed until "Trigger Rule Action" is confirmed per item.
  # Jellyfin/Sonarr/Radarr/Seerr are set in the web UI (stored in its SQLite DB)
  # as http://host.containers.internal:<port>; podman0 ports in hosts/boba/default.nix.
  virtualisation.oci-containers.containers.maintainerr = {
    # Pinned: it deletes media, so upgrades are deliberate.
    image = "ghcr.io/maintainerr/maintainerr:3.31.0";
    autoStart = true;
    user = "${toString media.uid}:${toString media.gid}";
    ports = ["127.0.0.1:${toString config.homelab.published.maintainerr.proxyTo}:6246"];
    environment = {
      TZ = "America/New_York";
      TELEMETRY = "off";
    };
    volumes = ["${dataDir}:/opt/data:rw"];
  };

  homelab.published.maintainerr.proxyTo = 6246;
}
