{
  homelab = {
    domain = "lanice.dev";
    tailscaleIP = "100.124.185.117";
  };

  imports = [
    ../../common/publishing.nix

    ./adguard.nix
    ./audiobookrequest.nix
    ./aurral.nix
    ./bookorbit
    ./explo.nix
    ./forgejo-runner.nix
    ./healthcheck.nix
    ./homepage.nix
    ./librechat.nix
    ./lidarr.nix
    ./media-estate.nix
    ./media.nix
    ./oink.nix
    ./paperless.nix
    ./peertube.nix
    ./sabnzbd.nix
    ./scrutiny.nix
    ./sillytavern.nix
    ./soulseek.nix
    ./speedtest-tracker.nix
    ./stirlingpdf.nix
    ./syncthing.nix
    ./tracearr.nix
    ./uptime-kuma.nix
    ./wan-monitor.nix
    ./zfs-zed.nix

    ./minecraft
  ];
}
