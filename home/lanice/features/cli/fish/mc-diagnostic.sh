#!/usr/bin/env bash
# One-shot status report for boba MC hosting. Run remotely via ssh.
# Usage: mc_diagnostic [--deep]    (--deep adds mtr per-hop reports)
set -u
LOG=/var/lib/minecraft/atm10_2026/logs/latest.log
DEEP=0
[ "${1:-}" = "--deep" ] && DEEP=1

hr() { printf '\n\033[1;36m== %s ==\033[0m\n' "$1"; }

# ---------- Gather: MC log parsing ----------
# Currently online (player, last-login-ts, last-login-src)
ONLINE_TSV=$(awk '
  match($0, /^\[([^]]+)\].*Server thread\/INFO.*PlayerList.*: ([A-Za-z0-9_]+)\[\/([^]]+)\] logged in/, m) {
    last_ts[m[2]] = m[1]; last_src[m[2]] = m[3]; online[m[2]] = 1
  }
  /Server thread\/INFO.*left the game/ { delete online[$(NF-3)] }
  END { for (p in online) print p "\t" last_ts[p] "\t" last_src[p] }
' "$LOG")

# Recent timeouts (to-ts, player, login-ts, login-src) — last 10
TIMEOUT_TSV=$(awk '
  match($0, /^\[([^]]+)\].*Server thread\/INFO.*PlayerList.*: ([A-Za-z0-9_]+)\[\/([^]]+)\] logged in/, m) {
    last_ts[m[2]] = m[1]; last_src[m[2]] = m[3]
  }
  match($0, /^\[([^]]+)\].*Server thread\/INFO.*: ([A-Za-z0-9_]+) lost connection: Timed out/, m) {
    print m[1] "\t" m[2] "\t" (m[2] in last_ts ? last_ts[m[2]] : "?") "\t" (m[2] in last_src ? last_src[m[2]] : "?")
  }
' "$LOG" | tail -10)

# ---------- Gather: tailscale ----------
TS_JSON=$(tailscale status --json 2>/dev/null || echo "{}")

# Tailnet IPs of all currently active shared peers (one per line).
ACTIVE_SHARED=$(echo "$TS_JSON" | jq -r '
  .Peer | to_entries[]
  | select(.value.Active == true and ((.value.DNSName // "") == ""))
  | .value.TailscaleIPs[0]
')

# Build a map: shared-peer tailnet IP -> MC player name, by intersecting
# each peer's historical public endpoints (from `tailscale debug
# peer-endpoint-changes`) with the public IPs each player has ever logged
# in from (in the current MC log). Public IPs are the only cross-system
# identifier we can observe — container logs show 10.88.0.1 as the source
# for all tailnet players, so we can't match there.
#
# Also include all shared peers (not just active ones) so timed-out
# players can also be labeled.
ALL_SHARED=$(echo "$TS_JSON" | jq -r '
  .Peer | to_entries[]
  | select((.value.DNSName // "") == "")
  | .value.TailscaleIPs[0]
')

# MC log: unique (public_ip, player) pairs. Filters 10.88.0.1 (tailnet NAT).
PLAYER_IPS_TSV=$(awk '
  match($0, /.*: ([A-Za-z0-9_]+)\[\/([^]]+)\] logged in/, m) {
    src=m[2]; sub(/:.*/, "", src)
    if (src != "10.88.0.1") {
      key = src "\t" m[1]
      if (!(key in seen)) { seen[key]=1; print key }
    }
  }
' "$LOG")

SHARED_PEER_MAP=""
while read -r peer_ts_ip; do
  [ -z "$peer_ts_ip" ] && continue
  # Public IPv4 endpoints this peer has advertised, minus RFC1918.
  peer_ips=$(tailscale debug peer-endpoint-changes "$peer_ts_ip" 2>/dev/null \
    | jq -r '
        .[] | select(.What == "updateFromNode-new-Endpoints") | .To[]?
        | select(type == "string")
        | select(test("^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+:"))
        | split(":")[0]
      ' 2>/dev/null \
    | grep -vE '^(10\.|192\.168\.|172\.(1[6-9]|2[0-9]|3[01])\.)' \
    | sort -u)
  [ -z "$peer_ips" ] && continue
  # Find a player whose known public IPs intersect peer_ips.
  matched=$(printf '%s\n' "$PLAYER_IPS_TSV" | awk -F'\t' -v ips="$peer_ips" '
    BEGIN { n=split(ips, a, "\n"); for (i=1;i<=n;i++) have[a[i]]=1 }
    ($1 in have) { print $2; exit }
  ')
  [ -n "$matched" ] && SHARED_PEER_MAP="$SHARED_PEER_MAP$peer_ts_ip	$matched
"
done <<< "$ALL_SHARED"

# Classify an MC login source "ip:port" as via-tailnet or direct-public.
# Args: $1 = "ip:port", $2 = MC player name (used to look up the specific
# tailscale peer via SHARED_PEER_MAP). If the player is matched, reports
# that peer's path specifically. Otherwise aggregates all active shared
# peers (ambiguous fallback).
classify_src() {
  local src="$1" player="$2" ip
  ip=$(echo "$src" | cut -d: -f1)
  if [ "$ip" != "10.88.0.1" ]; then
    echo "DIRECT public $ip"
    return
  fi
  # Find this player's matched peer tailnet IP (if any).
  local peer_ip
  peer_ip=$(printf '%s' "$SHARED_PEER_MAP" | awk -F'\t' -v n="$player" '$2==n {print $1; exit}')
  if [ -n "$peer_ip" ]; then
    local path
    path=$(echo "$TS_JSON" | jq -r --arg ip "$peer_ip" '
      .Peer[] | select(.TailscaleIPs[0] == $ip)
      | if .CurAddr == "" then "DERP(" + .Relay + ")" else "DIRECT " + .CurAddr end
    ')
    echo "VIA TAILNET → $path [peer $peer_ip]"
  else
    # Unmatched — aggregate all active shared peer paths, joined by ", ".
    local tailnet_paths
    tailnet_paths=$(echo "$TS_JSON" | jq -r '
      .Peer | to_entries[]
      | select(.value.Active == true and ((.value.DNSName // "") == ""))
      | if .value.CurAddr == "" then "DERP(" + .value.Relay + ")" else "DIRECT " + .value.CurAddr end
    ' | awk 'NR>1{printf ", "} {printf "%s", $0} END{if(NR) print ""}')
    if [ -z "$tailnet_paths" ]; then
      echo "VIA TAILNET (unmatched, no active shared peer!)"
    else
      echo "VIA TAILNET → $tailnet_paths (unmatched, ambiguous)"
    fi
  fi
}

# ---------- Render ----------
hr "SERVER HEALTH"
uptime
podman stats --no-stream minecraft-atm10-2026 2>/dev/null || echo "container not running"

hr "MC — CURRENTLY ONLINE"
if [ -z "$ONLINE_TSV" ]; then
  echo "  (nobody)"
else
  while IFS=$'\t' read -r player ts src; do
    method=$(classify_src "$src" "$player")
    printf "  %s  %-20s → %s\n" "$ts" "$player" "$method"
  done <<< "$ONLINE_TSV"
fi

hr "CONNECTION QUALITY TO ONLINE PLAYERS"
if [ -z "$ONLINE_TSV" ]; then
  echo "  (nobody online)"
else
  while IFS=$'\t' read -r player ts src; do
    ip=$(echo "$src" | cut -d: -f1)
    echo "  $player"
    if [ "$ip" = "10.88.0.1" ]; then
      # Tailnet — if player is matched in SHARED_PEER_MAP, probe only
      # their specific peer. Otherwise fan out across all active shared
      # peers as a fallback (helps identify which peer is them).
      matched_peer=$(printf '%s' "$SHARED_PEER_MAP" | awk -F'\t' -v n="$player" '$2==n {print $1; exit}')
      if [ -n "$matched_peer" ]; then
        echo "    tailscale ping $matched_peer (matched):"
        timeout 8 tailscale ping -c 3 --timeout 2s "$matched_peer" 2>&1 | sed 's/^/      /'
      elif [ -z "$ACTIVE_SHARED" ]; then
        echo "    (no active shared peer to probe)"
      else
        echo "    (unmatched — probing all active shared peers)"
        while read -r ts_ip; do
          [ -z "$ts_ip" ] && continue
          echo "    tailscale ping $ts_ip:"
          timeout 8 tailscale ping -c 3 --timeout 2s "$ts_ip" 2>&1 | sed 's/^/      /'
        done <<< "$ACTIVE_SHARED"
      fi
    else
      echo "    ping $ip:"
      ping -c 3 -W 2 -q "$ip" 2>&1 | tail -2 | sed 's/^/      /'
    fi
  done <<< "$ONLINE_TSV"
fi

hr "MC — LAST 10 CONNECTION EVENTS"
grep -E "logged in|lost connection|joined the game|left the game" "$LOG" 2>/dev/null \
  | tail -10 \
  | sed -E 's/^(\[[^]]+\]).*\]: /\1 /'

hr "MC — RECENT TIMEOUTS (with login path)"
if [ -z "$TIMEOUT_TSV" ]; then
  echo "  (none)"
else
  while IFS=$'\t' read -r to_ts player login_ts src; do
    method=$(classify_src "$src" "$player")
    printf "  %s  %s — last login %s %s\n" "$to_ts" "$player" "$login_ts" "$method"
  done <<< "$TIMEOUT_TSV"
fi

hr "TELEKOM PATH (last 1h)"
LOSS=$(journalctl --since "1 hour ago" -u wan-ping-telekom 2>/dev/null | grep -c "no answer")
echo "No-answer count (last 1h): $LOSS"

hr "IPTABLES DROP RULES"
iptables -L OUTPUT -n -v | awk 'NR==1 || NR==2 || /DROP/'

hr "TAILSCALE ACTIVE PEERS"
# Render via jq, then rewrite the HostName column to the MC username for
# any peer whose tailnet IP we've matched in SHARED_PEER_MAP.
echo "$TS_JSON" | jq -r '
  .Peer | to_entries[]
  | select(.value.Active == true)
  | "\(.value.HostName // "peer")|\(.value.TailscaleIPs[0])|relay=\(.value.Relay)|path=\(if .value.CurAddr == "" then "RELAY" else "DIRECT " + .value.CurAddr end)|shared=\(if (.value.DNSName // "") == "" then "yes" else "no" end)"
' | awk -F'|' -v OFS='|' -v map="$SHARED_PEER_MAP" '
  BEGIN {
    n = split(map, lines, "\n")
    for (i=1; i<=n; i++) {
      if (lines[i] == "") continue
      split(lines[i], parts, "\t")
      m[parts[1]] = parts[2]
    }
  }
  { if ($2 in m) $1 = "mc:" m[$2]; print "  " $0 }
' | column -t -s '|'

if [ "$DEEP" = "1" ]; then
  hr "DEEP PROBE (mtr)"
  if ! command -v mtr >/dev/null 2>&1; then
    echo "  mtr not installed on boba"
  else
    # Collect unique targets: iptables DROP dests (known problem IPs) +
    # public-IP player sources + telekom backbone probe. Dedupe by IP.
    {
      iptables -L OUTPUT -n | awk '/DROP/ {print $5 "\tiptables DROP target"}'
      if [ -n "$ONLINE_TSV" ]; then
        while IFS=$'\t' read -r player _ src; do
          ip=$(echo "$src" | cut -d: -f1)
          if [ "$ip" != "10.88.0.1" ] && [ -n "$ip" ]; then
            printf '%s\tplayer: %s\n' "$ip" "$player"
          fi
        done <<< "$ONLINE_TSV"
      fi
      printf '194.25.0.60\ttelekom backbone probe\n'
    } | awk -F'\t' '!seen[$1]++' | while IFS=$'\t' read -r ip label; do
      [ -z "$ip" ] && continue
      echo "  → $ip  ($label)"
      mtr --report --report-cycles 3 --no-dns -w "$ip" 2>&1 | sed 's/^/    /' \
        || echo "    (mtr failed)"
    done
  fi
fi

hr "WIFI DONGLE (should be silent)"
FLAPS=$(journalctl --since "1 hour ago" 2>/dev/null | grep -c "wlp0s20f0u9" || true)
AUTH=$(cat /sys/bus/usb/devices/3-9/authorized 2>/dev/null || echo "device-gone")
echo "Log events last 1h: $FLAPS (expect 0)"
echo "Authorized: $AUTH (expect 0)"

hr "IPv6 STATUS"
if ip -6 addr show enp95s0 2>/dev/null | grep -qE "inet6 2|inet6 3"; then
  ip -6 addr show enp95s0 | grep -E "inet6 2|inet6 3"
else
  echo "no public IPv6 (Frontier/eero — known issue)"
fi
