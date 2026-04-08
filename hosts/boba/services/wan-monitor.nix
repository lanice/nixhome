{
  lib,
  pkgs,
  ...
}: let
  targets = {
    cloudflare = "1.1.1.1";
    google = "8.8.8.8";
    telekom = "194.25.0.60";
    gateway = "192.168.4.1";
  };
in {
  systemd.services = lib.mapAttrs' (name: host:
    lib.nameValuePair "wan-ping-${name}" {
      description = "Continuous ping to ${name} (${host})";
      wantedBy = ["multi-user.target"];
      after = ["network-online.target"];
      wants = ["network-online.target"];
      serviceConfig = {
        ExecStart = "${pkgs.iputils}/bin/ping -D -O -n -i 1 ${host}";
        Restart = "always";
        RestartSec = "5s";
        DynamicUser = true;
        AmbientCapabilities = ["CAP_NET_RAW"];
      };
    })
  targets;
}
