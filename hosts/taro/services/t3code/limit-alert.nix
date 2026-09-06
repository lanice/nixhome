# Mail when t3code hits MemoryMax (oom_kill) or TasksMax (pids max).
# OOMPolicy=continue keeps the unit healthy, so OnFailure never fires;
# poll the cgroup event counters instead. A path unit on memory.events
# is unusable: the `high` counter churns under MemoryHigh throttling and
# would trip the start rate limit. MemoryHigh is not reported; it is
# noisy and self-correcting.
{
  config,
  pkgs,
  ...
}: let
  hostName = config.networking.hostName;
  cg = "/sys/fs/cgroup/system.slice/t3code.service";

  script = pkgs.writeShellScript "t3code-limit-alert" ''
    set -u
    counter() { ${pkgs.gawk}/bin/awk -v k="$2" '$1 == k {print $2}' "$1" 2>/dev/null || true; }
    prev() { cat "$STATE_DIRECTORY/$1" 2>/dev/null || echo 0; }

    oom=$(counter ${cg}/memory.events oom_kill); oom=''${oom:-0}
    pids=$(counter ${cg}/pids.events max);       pids=''${pids:-0}
    prev_oom=$(prev oom_kill)
    prev_pids=$(prev pids_max)
    # Counters reset when the service restarts.
    [ "$oom" -lt "$prev_oom" ] && prev_oom=0
    [ "$pids" -lt "$prev_pids" ] && prev_pids=0

    echo "$oom" >"$STATE_DIRECTORY/oom_kill"
    echo "$pids" >"$STATE_DIRECTORY/pids_max"

    [ "$oom" -gt "$prev_oom" ] || [ "$pids" -gt "$prev_pids" ] || exit 0

    # One incident bumps the counters many times; one mail per hour.
    stamp="$STATE_DIRECTORY/last-mail"
    [ -z "$(${pkgs.findutils}/bin/find "$stamp" -mmin -60 2>/dev/null)" ] || exit 0
    touch "$stamp"

    {
      printf 'To: root\n'
      printf 'Subject: [${hostName}] t3code hit a resource limit\n'
      printf 'MIME-Version: 1.0\nContent-Type: text/plain; charset=UTF-8\n\n'
      printf 'oom_kill: %s (was %s)\npids max: %s (was %s)\n\n' "$oom" "$prev_oom" "$pids" "$prev_pids"
      printf -- '--- memory.events ---\n'; cat ${cg}/memory.events
      printf -- '\n--- systemctl status ---\n'
      ${pkgs.systemd}/bin/systemctl status --full --lines=0 t3code.service || true
      printf -- '\n--- kernel/t3code journal, last 30 lines ---\n'
      ${pkgs.systemd}/bin/journalctl --unit=t3code.service --dmesg --lines=30 --no-pager
    } | ${pkgs.msmtp}/bin/msmtp --read-recipients
  '';
in {
  systemd.timers.t3code-limit-alert = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "2min";
      OnUnitActiveSec = "1min";
      AccuracySec = "10s";
    };
  };

  systemd.services.t3code-limit-alert = {
    description = "Mail on t3code cgroup limit counters";
    after = ["network-online.target"];
    wants = ["network-online.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = script;
      StateDirectory = "t3code-limit-alert";
    };
  };
}
