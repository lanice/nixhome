{
  pkgs,
  lib,
  inputs,
  ...
}: let
  inherit (lib) concatStringsSep;

  # Pin JRE versions used by instances
  jre8 = pkgs.temurin-bin-8;
  jre17 = pkgs.temurin-bin-17;

  # "Borrowed" from AllTheMods Discord
  jvmOpts = concatStringsSep " " [
    "-XX:+UseG1GC"
    "-XX:+ParallelRefProcEnabled"
    "-XX:MaxGCPauseMillis=200"
    "-XX:+UnlockExperimentalVMOptions"
    "-XX:+DisableExplicitGC"
    "-XX:+AlwaysPreTouch"
    "-XX:G1NewSizePercent=40"
    "-XX:G1MaxNewSizePercent=50"
    "-XX:G1HeapRegionSize=16M"
    "-XX:G1ReservePercent=15"
    "-XX:G1HeapWastePercent=5"
    "-XX:G1MixedGCCountTarget=4"
    "-XX:InitiatingHeapOccupancyPercent=20"
    "-XX:G1MixedGCLiveThresholdPercent=90"
    "-XX:G1RSetUpdatingPauseTimePercent=5"
    "-XX:SurvivorRatio=32"
    "-XX:+PerfDisableSharedMem"
    "-XX:MaxTenuringThreshold=1"
  ];

  defaults = {
    # Only people in the Cool Club (tm)
    white-list = true;

    # So I don't have to make everyone op
    spawn-protection = 0;

    # 5 minutes tick timeout, for heavy packs
    max-tick-time = 5 * 60 * 1000;

    # It just ain't modded minecraft without flying around
    allow-flight = true;
  };
in {
  imports = [inputs.minecraft-servers.module];
  services.modded-minecraft-servers = {
    eula = true;
    instances = {
      e2es = {
        enable = false;
        rsyncSSHKeys = [""];
        inherit jvmOpts;
        jvmMaxAllocation = "8G";
        jvmInitialAllocation = "2G";
        jvmPackage = jre8;
        serverConfig =
          defaults
          // {
            server-port = 25565;
            rcon-port = 25566;
            motd = "Enigmatica 2: Expert Skyblock";
            extra-options.level-type = "voidworld";
          };
      };

      atm8 = {
        enable = true;
        rsyncSSHKeys = [""];
        jvmOpts =
          jvmOpts
          + " "
          + (concatStringsSep " " [
            "-javaagent:log4jfix/Log4jPatcher-1.0.0.jar"
            "@libraries/net/minecraftforge/forge/1.19.2-43.2.6/unix_args.txt"
          ]);
        jvmPackage = jre17;
        jvmMaxAllocation = "12G";
        jvmInitialAllocation = "4G";
        serverConfig =
          defaults
          // {
            server-port = 25573;
            rcon-port = 25574;
            motd = "All the Mods 8 - ATM8";
            level-seed = "6269683411705152640";
          };
      };
    };
  };
}
