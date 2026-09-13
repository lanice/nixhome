{pkgs, ...}: {
  # Forward kernel messages to taro so crashes leave evidence off-box.
  # Destination is taro's reserved LAN IP and enp1s0 MAC.
  # Receiver: hosts/taro/services/netconsole-receiver.nix.
  systemd.services.netconsole = {
    description = "Stream kernel log to taro via netconsole";
    wantedBy = ["multi-user.target"];
    after = ["network-online.target" "sys-kernel-config.mount"];
    wants = ["network-online.target"];
    requires = ["sys-kernel-config.mount"];
    path = [pkgs.iproute2 pkgs.jq pkgs.kmod];
    script = ''
      source_ip=
      for _ in {1..60}; do
        if [[ $(cat /sys/class/net/enp95s0/carrier 2>/dev/null) == 1 ]]; then
          source_ip=$(ip -j -4 address show dev enp95s0 scope global | jq -r '.[0].addr_info[0].local // empty')
          if [[ -n "$source_ip" ]]; then
            break
          fi
        fi
        sleep 1
      done
      if [[ -z "$source_ip" ]]; then
        echo "netconsole: enp95s0 has no carrier or global IPv4 address after 60s" >&2
        exit 1
      fi

      modprobe netconsole
      target=/sys/kernel/config/netconsole/taro
      mkdir "$target"
      echo enp95s0 > "$target/dev_name"
      echo "$source_ip" > "$target/local_ip"
      echo 192.168.7.171 > "$target/remote_ip"
      echo 00:e0:4c:56:27:82 > "$target/remote_mac"
      echo 6666 > "$target/remote_port"
      echo 1 > "$target/extended"
      echo 1 > "$target/enabled"
      if [[ $(cat "$target/enabled") != 1 ]]; then
        echo "netconsole: kernel did not enable the taro target" >&2
        exit 1
      fi
    '';
    postStop = ''
      target=/sys/kernel/config/netconsole/taro
      if [[ -d "$target" ]]; then
        echo 0 > "$target/enabled"
        rmdir "$target"
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      TimeoutStartSec = 75;
    };
  };
}
