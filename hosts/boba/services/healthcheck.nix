{
  pkgs,
  inputs,
  config,
  ...
}: {
  age.secrets.healthcheck-uuid.file = "${inputs.self}/secrets/healthcheck-uuid.age";

  systemd.services.healthcheck-ping = {
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "healthcheck-ping" ''
        uuid=$(cat ${config.age.secrets.healthcheck-uuid.path})
        ${pkgs.curl}/bin/curl -fsS -m 10 --retry 5 "https://hc-ping.com/$uuid"
      '';
    };
  };

  systemd.timers.healthcheck-ping = {
    wantedBy = ["timers.target"];
    timerConfig = {
      # Every 5 minutes. UTC: in local time the DST fall-back repeats 01:xx and systemd skips it (65 min gap).
      OnCalendar = "*:0/5 UTC";
      RandomizedDelaySec = "30s";
    };
  };
}
