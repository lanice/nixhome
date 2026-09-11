{
  config,
  inputs,
  pkgs,
  ...
}: let
  home = config.users.users.coding.home;
  package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.herdr;
in {
  systemd.tmpfiles.rules = [
    "d ${home}/.config 0700 coding coding -"
    "d ${home}/.config/herdr 0700 coding coding -"
  ];

  systemd.services.herdr = {
    description = "Herdr remote coding terminals";
    environment.XDG_CONFIG_HOME = "${home}/.config";
    serviceConfig = {
      ExecStart = "${package}/bin/herdr server";
      KillMode = "control-group";
    };
  };
}
