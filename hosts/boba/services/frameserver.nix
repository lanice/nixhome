{
  inputs,
  lib,
  pkgs,
  ...
}: let
  package = inputs.inkprep.packages.${pkgs.stdenv.hostPlatform.system}.frameserver;
  photos = "/var/lib/inkplate-photos";
  state = "/var/lib/frameserver";
  port = 8460;
  lanGuards = [
    "-d 192.168.4.41 -p tcp --dport ${toString port} ! -i enp95s0 -j DROP"
    "-d 192.168.4.41 -p tcp --dport ${toString port} ! -s 192.168.4.0/22 -j DROP"
  ];
in {
  services.syncthing.settings.folders.inkplate-photos = {
    path = photos;
    devices = ["longjing"];
    ignorePerms = true; # Keep receiver permissions readable by the service.
  };
  systemd.tmpfiles.rules = ["d ${photos} 0750 syncthing syncthing -"];

  users.users.frameserver = {
    isSystemUser = true;
    group = "frameserver";
  };
  users.groups.frameserver = {};

  systemd.services.frameserver = {
    description = "Inkplate photo rotation";
    wantedBy = ["multi-user.target"];
    wants = ["network-online.target"];
    after = ["network-online.target" "zfs-mount.service"];
    requires = ["zfs-mount.service"];
    serviceConfig = {
      ExecStart = lib.escapeShellArgs [
        (lib.getExe package)
        photos
        "--state"
        state
        "--host"
        "192.168.4.41"
        "--port"
        (toString port)
        "--tz"
        "America/New_York"
        "--quiet"
        "4-11"
      ];
      User = "frameserver";
      Group = "frameserver";
      SupplementaryGroups = ["syncthing"];
      StateDirectory = "frameserver";
      StateDirectoryMode = "0700";
      UMask = "0077";
      Restart = "on-failure";
      RestartSec = "5s";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      RestrictSUIDSGID = true;
      RestrictAddressFamilies = ["AF_UNIX" "AF_INET"];
      CapabilityBoundingSet = "";
      # Numba's LLVM JIT needs executable writable memory.
      MemoryDenyWriteExecute = false;
    };
  };

  # Raw prerouting precedes Tailscale's ts-input ACCEPT and nixos-fw trust.
  networking.firewall = {
    interfaces.enp95s0.allowedTCPPorts = [port];
    extraCommands =
      lib.concatMapStringsSep "\n" (rule: ''
        iptables -t raw -C PREROUTING ${rule} 2>/dev/null || iptables -t raw -I PREROUTING ${rule}
      '')
      lanGuards;
    extraStopCommands =
      lib.concatMapStringsSep "\n" (rule: ''
        iptables -t raw -D PREROUTING ${rule} 2>/dev/null || true
      '')
      lanGuards;
  };
}
