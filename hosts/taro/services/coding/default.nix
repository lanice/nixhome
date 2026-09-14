{
  config,
  lib,
  pkgs,
  ...
}: let
  fleet = import ../../../fleet.nix;
  account = config.users.users.coding;
  slice = "user-${toString account.uid}";
  agenixServices = lib.optional (config.systemd.sysusers.enable || config.services.userborn.enable) "agenix-install-secrets.service";
in {
  imports = [./limit-alert.nix];

  users.groups.coding.gid = 988;
  users.users.coding = {
    isNormalUser = true;
    uid = 1001;
    group = "coding";
    home = "/home/coding";
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
    Match User coding
      AuthenticationMethods publickey
      PasswordAuthentication no
      KbdInteractiveAuthentication no
      AllowAgentForwarding no
    Match all
  '';

  home-manager.users.coding = import ./home.nix;
  fleet.workspaceSecrets.account = "coding";

  systemd.tmpfiles.rules = map (path: "d ${account.home}${path} 0700 coding coding -") [
    ""
    "/.ssh"
    "/workspaces"
  ];

  # Include both servers, their children and direct SSH sessions in one budget.
  systemd.slices.${slice}.sliceConfig = {
    MemoryHigh = "9G";
    MemoryMax = "10G";
    TasksMax = 4096;
    CPUWeight = 50;
    IOWeight = 50;
  };

  systemd.services =
    lib.genAttrs ["t3code" "herdr"] (_: {
      wantedBy = ["multi-user.target"];
      after = ["network.target" "home-manager-coding.service"] ++ agenixServices;
      requires = ["home-manager-coding.service"] ++ agenixServices;
      path = [
        "/etc/profiles/per-user/coding"
        "${account.home}/.nix-profile"
        "/run/current-system/sw"
      ];
      environment = {
        HOME = account.home;
        SHELL = lib.getExe account.shell;
      };
      serviceConfig = {
        User = "coding";
        Group = "coding";
        Slice = "${slice}.slice";
        WorkingDirectory = "${account.home}/workspaces";
        Restart = "always";
        RestartSec = 5;
        UMask = "0077";
        NoNewPrivileges = true;
        OOMPolicy = "continue";
        TasksMax = 4096;
      };
    })
    // {
      # Daemon builds escape the account's cgroup.
      nix-daemon.serviceConfig = {
        MemoryHigh = "2G";
        MemoryMax = "3G";
        CPUWeight = 25;
        IOWeight = 25;
      };
    };

  # Keep daemon builds within the remaining host budget.
  nix.settings = {
    max-jobs = 1;
    cores = 2;
  };
}
