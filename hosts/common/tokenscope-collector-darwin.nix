# launchd twin of tokenscope-collector.nix; same options, paths and flags.
# No systemd sandboxing or LoadCredential: the token is owned by the account.
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
  logDir = "/var/log/tokenscope";
  unitName = tool: "tokenscope-collect-${tool}";
  stateDirectory = tool: "/var/lib/tokenscope/${host}/coding/${tool}/${destinationId}";
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
      owner = cfg.account;
      group = "staff";
      mode = "0400";
    };

    # launchd creates neither state nor log directories.
    system.activationScripts.extraActivation.text =
      lib.concatMapStrings (tool: ''
        install -d -m 0755 ${lib.escapeShellArg (dirOf (stateDirectory tool))}
        install -d -m 0700 -o ${cfg.account} -g staff ${lib.escapeShellArg (stateDirectory tool)}
      '')
      cfg.tools
      + ''
        install -d -m 0700 -o ${cfg.account} -g staff ${logDir}
      '';

    environment.etc."newsyslog.d/tokenscope.conf".text = ''
      ${logDir}/*.log ${cfg.account}:staff 600 4 1024 * GN
    '';

    launchd.daemons = lib.genAttrs (map unitName cfg.tools) (name: let
      tool = lib.removePrefix "tokenscope-collect-" name;
    in {
      serviceConfig = {
        ProgramArguments = [
          "${package}/bin/tokenscope"
          "collect"
          "--tool=${tool}"
          "--root=${roots.${tool}}"
          "--state=${stateDirectory tool}"
          "--host=${host}"
          "--destination=${destination}"
          "--token-file=${config.age.secrets.${secret}.path}"
          # Packaged pricing avoids a second network dependency during catch-up.
          "--offline"
          # Full-history discovery reuses cached parsing and offline aggregates.
          "--timeout=45m"
        ];
        UserName = cfg.account;
        Umask = 63; # 0077
        # Hourly; a slot missed asleep runs once on wake.
        StartCalendarInterval = [{Minute = 0;}];
        # Retry failures (e.g. offline) no sooner than 15 min. Implies a run at load.
        KeepAlive.SuccessfulExit = false;
        ThrottleInterval = 900;
        ProcessType = "Background";
        StandardOutPath = "${logDir}/${tool}.log";
        StandardErrorPath = "${logDir}/${tool}.log";
      };
    });
  };
}
