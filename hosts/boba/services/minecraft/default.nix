{
  inputs,
  config,
  ...
}: let
  atm10Dir = "/var/lib/minecraft/atm10";

  port_container = 25565;
  port_public = 25565;
in {
  age.secrets.curseforge.file = "${inputs.self}/secrets/curseforge.age";

  systemd.tmpfiles.rules = [
    "d ${atm10Dir} 0770 root users -"
  ];

  virtualisation.oci-containers.containers = {
    minecraft-atm10 = {
      autoStart = true;
      image = "itzg/minecraft-server:latest";
      volumes = [
        "${atm10Dir}:/data"
        "${toString ./patches}:/patches"
      ];
      ports = ["${toString port_public}:${toString port_container}"];

      environmentFiles = [config.age.secrets.curseforge.path];
      environment = {
        DEBUG = "true";
        DEBUG_EXEC = "true";

        TZ = "America/New_York";
        EULA = "TRUE";
        TYPE = "AUTO_CURSEFORGE";
        CF_SLUG = "all-the-mods-10";
        CF_FILE_ID = "6152362";
        CF_OVERRIDES_EXCLUSIONS = "shaderpacks/**";
        WHITELIST = "lanice,Deimops,Clyntax,FlyingPengwing,Lowista,BooNici,Kreativlabor";
        # SERVER_PORT = "${toString port_container}";

        INIT_MEMORY = "4G";
        MAX_MEMORY = "12G";
        USE_AIKAR_FLAGS = "true";

        SERVER_NAME = "MeinKraft ATM10";
        MOTD = "kek";
        ICON = "https://i.postimg.cc/vZgh2sJQ/minecraft.jpg";

        SEED = "-436188160836958048";
        ALLOW_FLIGHT = "TRUE";
        SPAWN_PROTECTION = "0";

        PATCH_DEFINITIONS = "/patches";

        # ONLINE_MODE = "TRUE";
        # ENABLE_WHITELIST = "TRUE";

        JVM_OPTS = "-Dfml.readTimeout=180";
      };
      extraOptions = [
        "--hostname=minecraft-atm10"
        "--pull=newer"
        "-it"

        # "--health-cmd"
        # "mc-health"
        # "--health-interval"
        # "10s"
        # "--health-retries"
        # "6"
        # "--health-timeout"
        # "1s"
        # "--health-start-period"
        # "20m"
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [port_public];
}
