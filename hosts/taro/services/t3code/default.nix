{
  config,
  inputs,
  pkgs,
  ...
}: let
  fleet = import ../../../fleet.nix;
  package = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.t3code-server;
  home = "/home/t3code";
  pub = config.homelab.published.t3code;
in {
  users.groups.t3code = {};
  users.users.t3code = {
    isNormalUser = true;
    group = "t3code";
    inherit home;
    createHome = true;
    homeMode = "0700";
    shell = pkgs.bashInteractive;
    hashedPassword = "!";
    openssh.authorizedKeys.keys = [
      fleet.users.lanice-sencha
      fleet.users.lanice-longjing
    ];
  };

  services.openssh.extraConfig = ''
    Match User t3code
      AuthenticationMethods publickey
      PasswordAuthentication no
      KbdInteractiveAuthentication no
    Match all
  '';

  home-manager.users.t3code = import ./home.nix;

  systemd.tmpfiles.rules = [
    "d ${home} 0700 t3code t3code -"
    "d ${home}/.ssh 0700 t3code t3code -"
    "d ${home}/.t3 0700 t3code t3code -"
    "d ${home}/.codex 0700 t3code t3code -"
    "d ${home}/workspaces 0700 t3code t3code -"
  ];

  systemd.services.t3code = {
    description = "T3 Code remote coding environment";
    wantedBy = ["multi-user.target"];
    after = ["network.target" "home-manager-t3code.service"];
    requires = ["home-manager-t3code.service"];

    # Match SSH's user and system profiles, including nix and Codex.
    path = [
      "/etc/profiles/per-user/t3code"
      "${home}/.nix-profile"
      "/run/current-system/sw"
    ];
    environment = {
      HOME = home;
      SHELL = "${pkgs.bashInteractive}/bin/bash";
    };

    serviceConfig = {
      User = "t3code";
      Group = "t3code";
      WorkingDirectory = "${home}/workspaces";
      ExecStart = "${package}/bin/t3 serve --host 127.0.0.1 --port ${toString pub.proxyTo} --base-dir ${home}/.t3";
      Restart = "always";
      RestartSec = 5;
      KillMode = "mixed";
      UMask = "0077";
      # Keep home writes, network access and the unprivileged Nix daemon usable.
      NoNewPrivileges = true;
    };
  };

  homelab.published.t3code = {
    proxyTo = 3773;
    reachable = "tailnet";
  };
}
