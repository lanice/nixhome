{
  inputs,
  config,
  pkgs,
  ...
}: let
  package = inputs.tokenscope.packages.${pkgs.stdenv.hostPlatform.system}.tokenscope;
  port = 8097;
in {
  age.secrets.tokenscopeGrants.file = "${inputs.self}/secrets/tokenscopeGrants.age";

  users.users.tokenscope = {
    isSystemUser = true;
    group = "tokenscope";
  };
  users.groups.tokenscope = {};

  systemd.services.tokenscope = {
    description = "Tokenscope usage and project reports";
    wantedBy = ["multi-user.target"];
    after = ["zfs-mount.service"];
    requires = ["zfs-mount.service"];
    restartTriggers = [config.age.secrets.tokenscopeGrants.file];
    serviceConfig = {
      ExecStart = "${package}/bin/tokenscope serve --listen 127.0.0.1:${toString port} --state /var/lib/tokenscope/usage.sqlite --credentials %d/grants.json";
      LoadCredential = "grants.json:${config.age.secrets.tokenscopeGrants.path}";
      User = "tokenscope";
      Group = "tokenscope";
      StateDirectory = "tokenscope";
      StateDirectoryMode = "0700";
      UMask = "0077";
      Restart = "on-failure";
      RestartSec = "5s";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      RestrictSUIDSGID = true;
      RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6"];
      CapabilityBoundingSet = "";
    };
  };

  homelab.published.tokenscope = {
    proxyTo = port;
    reachable = "tailnet";
  };
}
