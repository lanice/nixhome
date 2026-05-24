{
  _module.args.tailscaleIP = "100.124.185.117";

  imports = [
    ./adguard.nix
    ./audiobookrequest.nix
    ./aurral.nix
    ./bookshelf.nix
    ./explo.nix
    ./healthcheck.nix
    ./homepage.nix
    ./librechat.nix
    ./media.nix
    ./nginx.nix
    ./oink.nix
    ./paperless.nix
    ./peertube.nix
    ./sabnzbd.nix
    ./scrutiny.nix
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
