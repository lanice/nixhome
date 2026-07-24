# Long-running RAM sizing harness, to answer "how much RAM does the next
# laptop actually need?".
#
# Two layers:
#
#   1. services.sysstat — standard sar collection (every minute), giving the
#      usual retrospective trend data in /var/log/sa. Query with e.g.
#        sar -r            # today's memory stats
#        sar -r -f /var/log/sa/sa14
#      Point samples only: it cannot see a spike between two ticks, so it is
#      the baseline, not the peak measurement.
#
#   2. ram-monitor — a tiny always-on sampler that reads /proc/meminfo every
#      2s and writes a 30s bucket holding the *high-water mark* seen inside
#      that bucket. It also records PSI (/proc/pressure/memory) and, whenever
#      a new all-time peak is set, snapshots the top RSS consumers so the peak
#      can be attributed to actual processes.
#
# Report with:  ram-report [--days N] [--peaks]
#
# Why PSI matters more than the raw peak: Linux grows "used" opportunistically,
# so MemTotal-MemAvailable drifting high does not by itself mean more RAM was
# needed. Sustained non-zero memory PSI (and swap being touched) is the signal
# that the machine was genuinely short.
{pkgs, ...}: let
  stateDir = "/var/lib/ram-monitor";
  csv = "${stateDir}/samples.csv";
  peakFile = "${stateDir}/peak.txt";
  peakLog = "${stateDir}/peaks.log";

  # Inner sampling tick, and how often a bucket is flushed to the CSV.
  tickSeconds = 2;
  bucketSeconds = 30;

  # A new peak must beat the old one by this much (MiB) to be snapshotted,
  # and snapshots are rate-limited, so a slow ramp does not spam the log.
  peakDeltaMib = 256;
  peakMinGapSeconds = 60;

  sampler = pkgs.writeShellApplication {
    name = "ram-monitor-sample";
    runtimeInputs = [pkgs.coreutils pkgs.procps pkgs.gawk];
    text = ''
      csv="${csv}"
      peakfile="${peakFile}"
      peaklog="${peakLog}"

      mkdir -p "${stateDir}"
      if [ ! -s "$csv" ]; then
        echo "epoch,iso_time,used_mib_max,avail_mib_min,cache_mib,swap_used_mib_max,psi_some_us,psi_full_us" > "$csv"
      fi

      # /proc/meminfo and /proc/pressure/memory are parsed with pure bash so the
      # 2s tick costs no forks at all.
      read_mem() {
        MEM_TOTAL=0; MEM_AVAIL=0; BUFFERS=0; CACHED=0; SWAP_TOTAL=0; SWAP_FREE=0
        while read -r key val _; do
          case "$key" in
            MemTotal:)     MEM_TOTAL=$val ;;
            MemAvailable:) MEM_AVAIL=$val ;;
            Buffers:)      BUFFERS=$val ;;
            Cached:)       CACHED=$val ;;
            SwapTotal:)    SWAP_TOTAL=$val ;;
            SwapFree:)     SWAP_FREE=$val ;;
          esac
        done < /proc/meminfo
      }

      # Cumulative stall counters in microseconds since boot. They reset across
      # reboots; ram-report only sums positive deltas so that is handled.
      read_psi() {
        PSI_SOME=0; PSI_FULL=0
        [ -r /proc/pressure/memory ] || return 0
        while read -r kind _ _ _ tot; do
          case "$kind" in
            some) PSI_SOME=''${tot#total=} ;;
            full) PSI_FULL=''${tot#total=} ;;
          esac
        done < /proc/pressure/memory
      }

      globalpeak=0
      if [ -s "$peakfile" ]; then
        globalpeak=$(cat "$peakfile")
      fi
      case "$globalpeak" in
        "" | *[!0-9]*) globalpeak=0 ;;
      esac

      win_start=0
      win_used_max=0
      win_avail_min=0
      win_swap_max=0
      last_snap=0

      while true; do
        read_mem
        read_psi
        printf -v now '%(%s)T' -1

        # "used" = MemTotal - MemAvailable: what the workload actually demanded,
        # excluding reclaimable page cache. This is the number that matters for
        # sizing, not the `free` "used" column.
        used_mib=$(( (MEM_TOTAL - MEM_AVAIL) / 1024 ))
        avail_mib=$(( MEM_AVAIL / 1024 ))
        cache_mib=$(( (CACHED + BUFFERS) / 1024 ))
        swap_used_mib=$(( (SWAP_TOTAL - SWAP_FREE) / 1024 ))

        if [ "$win_start" -eq 0 ]; then
          win_start=$now
          win_used_max=$used_mib
          win_avail_min=$avail_mib
          win_swap_max=$swap_used_mib
        else
          if [ "$used_mib" -gt "$win_used_max" ]; then win_used_max=$used_mib; fi
          if [ "$avail_mib" -lt "$win_avail_min" ]; then win_avail_min=$avail_mib; fi
          if [ "$swap_used_mib" -gt "$win_swap_max" ]; then win_swap_max=$swap_used_mib; fi
        fi

        # New all-time peak: record who was holding the memory.
        if [ "$used_mib" -gt $((globalpeak + ${toString peakDeltaMib})) ] &&
           [ $((now - last_snap)) -ge ${toString peakMinGapSeconds} ]; then
          globalpeak=$used_mib
          last_snap=$now
          echo "$globalpeak" > "$peakfile"
          snapshot=$(ps -eo rss=,pid=,user=,comm= --sort=-rss)
          {
            printf '=== new peak %s MiB (%.1f GiB) at %(%F %T)T ===\n' \
              "$globalpeak" "$(awk -v m="$globalpeak" 'BEGIN{printf "%.1f", m/1024}')" "$now"
            printf 'avail=%s MiB  cache=%s MiB  swap_used=%s MiB\n' \
              "$avail_mib" "$cache_mib" "$swap_used_mib"

            # Per-process detail, then the same data rolled up by command. The
            # rollup is the useful one: browsers and builds fan out over dozens
            # of short-named workers ("Isolated", "cc1plus") that individually
            # look trivial and collectively dominate the peak.
            echo "  top processes:"
            printf '%s\n' "$snapshot" |
              head -n 12 |
              awk '{printf "  %8.1f MiB  pid %-8s %-9s %s\n", $1/1024, $2, $3, $4}'
            echo "  by command (summed RSS; shared pages counted per-process, so"
            echo "  a browser's total reads high vs. the real footprint):"
            printf '%s\n' "$snapshot" |
              awk '{s[$4] += $1; n[$4]++} END {for (k in s) printf "  %8.1f MiB  %4d x  %s\n", s[k]/1024, n[k], k}' |
              sort -rn |
              head -n 10
            echo
          } >> "$peaklog"
        fi

        if [ $((now - win_start)) -ge ${toString bucketSeconds} ]; then
          printf '%s,%(%F %T)T,%s,%s,%s,%s,%s,%s\n' \
            "$now" "$now" "$win_used_max" "$win_avail_min" \
            "$cache_mib" "$win_swap_max" "$PSI_SOME" "$PSI_FULL" >> "$csv"
          win_start=0
        fi

        sleep ${toString tickSeconds}
      done
    '';
  };

  report = pkgs.writeShellApplication {
    name = "ram-report";
    runtimeInputs = [pkgs.coreutils pkgs.gawk];
    text = ''
      csv="${csv}"
      peaklog="${peakLog}"

      days=0
      showpeaks=0

      while [ $# -gt 0 ]; do
        case "$1" in
          --days)
            days="$2"
            shift 2
            ;;
          --peaks)
            showpeaks=1
            shift
            ;;
          -h | --help)
            echo "usage: ram-report [--days N] [--peaks]"
            echo
            echo "  --days N   only consider the last N days of samples"
            echo "  --peaks    also print the recorded peak snapshots"
            exit 0
            ;;
          *)
            echo "ram-report: unknown argument: $1" >&2
            exit 1
            ;;
        esac
      done

      if [ ! -s "$csv" ]; then
        echo "ram-report: no samples yet at $csv" >&2
        echo "is ram-monitor running?  systemctl status ram-monitor" >&2
        exit 1
      fi

      printf -v nowts '%(%s)T' -1
      cutoff=0
      if [ "$days" -gt 0 ]; then
        cutoff=$((nowts - days * 86400))
      fi

      rows=$(mktemp)
      sorted=$(mktemp)
      trap 'rm -f "$rows" "$sorted"' EXIT

      awk -F, -v c="$cutoff" 'NR > 1 && $1 + 0 >= c' "$csv" > "$rows"
      if [ ! -s "$rows" ]; then
        echo "ram-report: no samples in the selected window" >&2
        exit 1
      fi
      cut -d, -f3 "$rows" | sort -n > "$sorted"

      total_kib=$(awk '/^MemTotal:/{print $2}' /proc/meminfo)

      awk -F, -v totkib="$total_kib" -v sorted="$sorted" '
        function gib(mib) { return sprintf("%6.1f GiB", mib / 1024) }
        {
          n++
          u = $3 + 0; a = $4 + 0; sw = $6 + 0; some = $7 + 0; full = $8 + 0
          if (u > umax)               { umax = u; umax_t = $2 }
          if (amin == "" || a < amin) { amin = a; amin_t = $2 }
          if (sw > swmax)             { swmax = sw; swmax_t = $2 }
          if (first == "")            { first = $2; ft = $1 + 0 }
          last = $2; lt = $1 + 0
          # Sum only positive deltas: the counters reset on reboot.
          if (psome != "") {
            d = some - psome; if (d > 0) some_us += d
            d = full - pfull; if (d > 0) full_us += d
          }
          psome = some; pfull = full
        }
        END {
          span = lt - ft
          if (span <= 0) span = 1

          # Percentiles from the pre-sorted used_mib column.
          m = 0
          while ((getline line < sorted) > 0) { v[++m] = line + 0 }
          split("50 90 99 99.9", plist, " ")

          printf "\nRAM report\n"
          printf "  window     %s  ->  %s\n", first, last
          printf "  duration   %.1f days   (%d samples, %ds buckets)\n", span / 86400, n, ${toString bucketSeconds}
          printf "  installed  %s\n\n", gib(totkib / 1024)

          printf "Demand (MemTotal - MemAvailable), peak within each bucket:\n"
          for (i = 1; i <= 4; i++) {
            p = plist[i] + 0
            idx = int(p / 100 * m); if (idx < 1) idx = 1; if (idx > m) idx = m
            printf "  p%-5s    %s\n", plist[i], gib(v[idx])
          }
          printf "  max       %s   at %s\n", gib(umax), umax_t
          printf "  min avail %s   at %s\n", gib(amin), amin_t
          printf "  max swap  %s   at %s\n\n", gib(swmax), (swmax > 0 ? swmax_t : "never")

          sec_some = some_us / 1000000
          sec_full = full_us / 1000000
          printf "Memory pressure (PSI cumulative stall):\n"
          printf "  some      %8.1f s   (%.4f%% of window)  some task delayed by reclaim\n", sec_some, 100 * sec_some / span
          printf "  full      %8.1f s   (%.4f%% of window)  everything stalled\n\n", sec_full, 100 * sec_full / span

          printf "Reading:\n"
          if (sec_full < 1 && swmax == 0) {
            printf "  No measurable pressure and swap never touched: %s of RAM was\n", gib(totkib / 1024)
            printf "  never a constraint in this window. The p99 of %s is the honest\n", gib(v[int(0.99 * m) < 1 ? 1 : int(0.99 * m)])
            printf "  floor for a replacement; the max is headroom, not a requirement.\n"
          } else {
            printf "  Non-zero stall or swap use: this window contains moments where the\n"
            printf "  machine was genuinely short. Size above the max, not the p99, and\n"
            printf "  check ram-report --peaks for what was resident at the time.\n"
          }
          printf "\n  Long-term trend from sar:  sar -r  |  sar -r -f /var/log/sa/saNN\n\n"
        }
      ' "$rows"

      if [ "$showpeaks" -eq 1 ]; then
        if [ -s "$peaklog" ]; then
          echo "Peak snapshots ($peaklog):"
          echo
          cat "$peaklog"
        else
          echo "No peak snapshots recorded yet."
        fi
      fi
    '';
  };
in {
  # Layer 1: standard sar collection. Every minute rather than the stock every
  # 10 minutes, which would observe ~0.2% of wall time.
  services.sysstat = {
    enable = true;
    collect-frequency = "*:*:00";
  };

  # Layer 2: the fine-grained peak tracker.
  systemd.services.ram-monitor = {
    description = "Peak RAM usage tracker (sizing harness)";
    wantedBy = ["multi-user.target"];
    after = ["local-fs.target"];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${sampler}/bin/ram-monitor-sample";
      Restart = "always";
      RestartSec = 5;
      StateDirectory = "ram-monitor";
      Nice = 10;

      # Reads /proc only; must not restrict /proc visibility or the peak
      # snapshots would miss other users' processes.
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectSystem = "strict";
      ProtectKernelTunables = true;
      ProtectControlGroups = true;
      RestrictAddressFamilies = ["AF_UNIX"];
      SystemCallFilter = ["@system-service"];
    };
  };

  environment.systemPackages = [report pkgs.sysstat];
}
