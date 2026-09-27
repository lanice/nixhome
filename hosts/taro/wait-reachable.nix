# Blocks until HOST:PORT accepts a TCP connection; fails after SECONDS
# (default 600). network-online.target is a no-op on taro (srvos masks both
# wait-online units), and after a power cut the router's DHCP, DNS and uplink
# lag taro's boot by minutes. Boot catch-up runs call this before touching
# the network.
#
#   wait-reachable HOST PORT [SECONDS]
{pkgs}:
pkgs.writeShellScript "wait-reachable" ''
  host="$1" port="$2" limit="''${3:-600}"
  deadline=$((SECONDS + limit))
  waited=
  until ${pkgs.coreutils}/bin/timeout 5 ${pkgs.bash}/bin/bash -c 'exec 3<>"/dev/tcp/$0/$1"' "$host" "$port" 2>/dev/null; do
    if [ "$SECONDS" -ge "$deadline" ]; then
      echo "$host:$port unreachable after ''${limit}s" >&2
      exit 1
    fi
    [ -n "$waited" ] || echo "waiting for $host:$port" >&2
    waited=1
    ${pkgs.coreutils}/bin/sleep 5
  done
  [ -z "$waited" ] || echo "$host:$port reachable after $SECONDS s" >&2
''
