{config, ...}: let
  atm10Dir = "/var/lib/minecraft/atm10";

  port = 25252;
in {
  age.secrets.curseforge.file = ../../../secrets/curseforge.age;

  systemd.tmpfiles.rules = [
    "d ${atm10Dir} 0770 root users -"
  ];

  virtualisation.oci-containers.containers = {
    minecraft-atm10 = {
      autoStart = false;
      image = "itzg/minecraft-server:latest";
      volumes = ["${atm10Dir}:/data"];
      ports = ["${toString port}:${toString port}"];
      environmentFiles = [config.age.secrets.curseforge.path];
      environment = {
        TZ = "America/New_York";
        EULA = "TRUE";
        TYPE = "AUTO_CURSEFORGE";
        CF_SLUG = "all-the-mods-10";
        INIT_MEMORY = "4G";
        MAX_MEMORY = "12G";
        USE_AIKAR_FLAGS = "true";

        SERVER_NAME = "MeinKraft ATM10";
        SERVER_PORT = "${toString port}";
        WHITELIST = "lanice,Deimops";
        ALLOW_FLIGHT = "TRUE";
        SPAWN_PROTECTION = "0";
      };
      extraOptions = [
        "--hostname=minecraft-atm10"
        "--health-cmd"
        "mc-health"
        "--health-interval"
        "10s"
        "--health-retries"
        "6"
        "--health-timeout"
        "1s"
        "--health-start-period"
        "20m"
        "--pull=newer"
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [port];
}
