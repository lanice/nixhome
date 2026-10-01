{name}: {
  config,
  inputs,
  pkgs,
  ...
}: let
  package = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.t3code-server;
  home = config.users.users.coding.home;
  pub = config.homelab.published.${name};
in {
  systemd.tmpfiles.rules = [
    "d ${home}/.t3 0700 coding coding -"
    "d ${home}/.codex 0700 coding coding -"
  ];

  systemd.services.${name} = {
    description = "T3 Code remote coding environment";
    serviceConfig = {
      ExecStart = "${package}/bin/t3 serve --host 127.0.0.1 --port ${toString pub.proxyTo} --base-dir ${home}/.t3";
      KillMode = "mixed";
    };
  };

  homelab.published.${name} = {
    proxyTo = 3773;
    reachable = "tailnet";
  };
}
