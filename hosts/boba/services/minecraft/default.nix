{
  inputs,
  config,
  pkgs,
  ...
}: let
  atm10_2026Dir = "/var/lib/minecraft/atm10_2026";
  motdFile = "/var/lib/minecraft/atm10_2026_motd.env";

  port_container = 25565;
  port_public = 25565;

  motds = [
    "MeinKraft: German Engineering"
    "Chunk loading intensifies"
    "Touch grass? We have Botania for that"
    "Redstone goes brrr"
    "It's not a bug, it's a feature mod"
    "This server runs on mass hopium and 12G of copium"
    "My therapist said I need boundaries. I built a wall of obsidian"
    "The lag isn't lag, it's dramatic pause"
    "I lost 4 hours to a hole. Not a cave. A HOLE"
    "Your base is mid. My dirt hut has SOUL"
    "The Ender Dragon filed a restraining order"
    "We don't have rules, we have suggestions that the server ignores"
    "Local man punches tree, accidentally starts industrial revolution"
    "TPS is just a number. A very sad number"
    "This modpack has more mods than I have braincells"
    "My computer is not on fire. That's a feature"
    "Accidental lava bucket placement is a love language"
    "I didn't grief your base, I renovated it aggressively"
    "The real treasure was the chunks we corrupted along the way"
    "Powered by sleep deprivation and questionable life choices"
    "All 300 mods are essential. Yes, even that one"
    "Lag spike? No that was the server taking a deep breath"
    "Our uptime is vibes-based"
    "Please do not feed the Warden. He is on a diet"
    "This MOTD was written at 3am and it shows"
    "Instructions unclear, automated the entire Nether"
    "Certified bruh moment generator since 2026"
  ];
in {
  age.secrets.curseforge.file = "${inputs.self}/secrets/curseforge.age";

  systemd.tmpfiles.rules = [
    "d ${atm10_2026Dir} 0770 root users -"
    "f ${motdFile} 0644 root root - MOTD=kek"
  ];

  virtualisation.oci-containers.containers = {
    minecraft-atm10-2026 = {
      autoStart = true;
      image = "itzg/minecraft-server:java21";
      volumes = [
        "${atm10_2026Dir}:/data"
        "${toString ./patches}:/patches"
      ];
      ports = ["${toString port_public}:${toString port_container}"];

      environmentFiles = [
        config.age.secrets.curseforge.path
        motdFile
      ];
      environment = {
        TZ = "America/New_York";
        EULA = "TRUE";
        TYPE = "AUTO_CURSEFORGE";
        CF_SLUG = "all-the-mods-10";
        CF_FILE_ID = "7852998";

        MEMORY = "12G";
        # USE_AIKAR_FLAGS = "true";
        USE_MEOWICE_FLAGS = "true";

        DIFFICULTY = "normal";
        MAX_PLAYERS = "10";
        ALLOW_FLIGHT = "TRUE";
        VIEW_DISTANCE = "12";
        SIMULATION_DISTANCE = "10";
        SPAWN_PROTECTION = "0";
        MAX_TICK_TIME = "-1";

        SERVER_NAME = "MeinKraft ATM10";
        ICON = "https://i.postimg.cc/vZgh2sJQ/minecraft.jpg";

        WHITELIST = "lanice,Deimops,Clyntax,FlyingPengwing,Lowista,BooNici,Kreativlabor";

        STOP_DURATION = "120";
        PATCH_DEFINITIONS = "/patches";
        # DISABLE_HEALTHCHECK = "true";
      };
      extraOptions = [
        "--tty"
        "--stop-timeout"
        "120"

        "--health-cmd"
        "mc-health"
        "--health-start-period"
        "20m"
        "--health-interval"
        "30s"
        "--health-retries"
        "6"
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [port_public];

  systemd.services.minecraft-atm10-2026-restart = {
    description = "Rotate MOTD and restart Minecraft ATM10";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "minecraft-motd-restart" ''
        motds=(${builtins.concatStringsSep " " (map (m: ''"${m}"'') motds)})
        index=$((RANDOM % ''${#motds[@]}))
        echo "MOTD=''${motds[$index]}" > ${motdFile}
        systemctl restart podman-minecraft-atm10-2026.service
      '';
    };
  };

  systemd.services.minecraft-atm10-2026-scheduled-restart = {
    description = "Warn players, rotate MOTD, and restart Minecraft ATM10";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "minecraft-scheduled-restart" ''
        ${pkgs.podman}/bin/podman exec minecraft-atm10-2026 rcon-cli say "Server restarting in 5 minutes!" || true
        sleep 240
        ${pkgs.podman}/bin/podman exec minecraft-atm10-2026 rcon-cli say "Server restarting in 1 minute!" || true
        sleep 55
        ${pkgs.podman}/bin/podman exec minecraft-atm10-2026 rcon-cli say "Server restarting now!" || true
        sleep 5
        systemctl start minecraft-atm10-2026-restart.service
      '';
    };
  };

  systemd.timers.minecraft-atm10-2026-scheduled-restart = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "daily";
      RandomizedDelaySec = "5m";
    };
  };

  systemd.services.minecraft-atm10-2026-player-log = {
    description = "Log Minecraft player join/leave events";
    after = ["podman-minecraft-atm10-2026.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "30";
      ExecStart = pkgs.writeShellScript "minecraft-player-log" ''
        ${pkgs.podman}/bin/podman logs -f --since 0s minecraft-atm10-2026 2>&1 \
          | ${pkgs.gnugrep}/bin/grep --line-buffered -E "joined the game|left the game" \
          >> /var/lib/minecraft/atm10_2026_players.log
      '';
    };
  };
}
