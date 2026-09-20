{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.fleet.tokenscopeCollector;
  host = config.networking.hostName;
  secret = "tokenscope${lib.strings.toSentenceCase host}";
  package = inputs.tokenscope.packages.${pkgs.stdenv.hostPlatform.system}.tokenscope;
  destination = "https://tokenscope.lanice.dev";
  destinationId = builtins.hashString "sha256" destination;
  home = config.users.users.${cfg.account}.home;
  roots = {
    claude = "${home}/.claude/projects";
    codex = "${home}/.codex";
    omp = "${home}/.omp/agent/sessions";
  };
  unitName = tool: "tokenscope-collect-${tool}";
in {
  options.fleet.tokenscopeCollector = {
    account = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "lanice";
      description = "Account whose coding histories are collected; null disables collection.";
    };
    tools = lib.mkOption {
      type = lib.types.listOf (lib.types.enum ["claude" "codex" "omp"]);
      default = [];
      description = "Supported histories to collect independently; missing roots fail rather than being created.";
    };
    t3State = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional read-only T3 database for retained worktree links.";
    };
  };

  config = lib.mkIf (cfg.account != null) {
    assertions = [
      {
        assertion = config.users.users ? ${cfg.account};
        message = "fleet.tokenscopeCollector.account must name an existing account.";
      }
    ];

    age.secrets.${secret} = {
      file = "${inputs.self}/secrets/${secret}.age";
      owner = "root";
      group = "root";
      mode = "0400";
    };

    systemd.services = lib.genAttrs (map unitName cfg.tools) (name: let
      tool = lib.removePrefix "tokenscope-collect-" name;
      stateDirectory = "tokenscope/${host}/coding/${tool}/${destinationId}";
    in {
      description = "Collect ${tool} usage for Tokenscope";
      wants = ["network-online.target"];
      after = ["network-online.target" "tailscaled.service"];
      restartTriggers = [config.age.secrets.${secret}.file];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = lib.concatStringsSep " " ([
            "${package}/bin/tokenscope collect"
            "--tool ${tool}"
            "--root ${roots.${tool}}"
            "--state /var/lib/${stateDirectory}"
            "--host ${host}"
            "--source coding"
            "--destination ${destination}"
            "--token-file %d/token"
            # Packaged pricing avoids a second network dependency during catch-up.
            "--offline"
            # Every pass scans all history, including changed old sessions.
            "--timeout 45m"
          ]
          ++ lib.optional (cfg.t3State != null) "--t3-state ${cfg.t3State}");
        LoadCredential = "token:${config.age.secrets.${secret}.path}";
        User = cfg.account;
        Group = config.users.users.${cfg.account}.group;
        StateDirectory = stateDirectory;
        StateDirectoryMode = "0700";
        UMask = "0077";
        TimeoutStartSec = "50min";
        Restart = "on-failure";
        RestartSec = "15min";
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        # Keep histories and Git/worktree evidence visible but never writable.
        ProtectHome = "read-only";
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        RestrictSUIDSGID = true;
        RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6"];
        CapabilityBoundingSet = "";
      };
    });

    systemd.timers = lib.genAttrs (map unitName cfg.tools) (_: {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "hourly";
        OnBootSec = "5min";
        Persistent = true;
      };
    });
  };
}
