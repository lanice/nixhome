{pkgs, ...}: {
  # Stream kernel messages to taro over the LAN so a hard crash leaves
  # evidence off-box. The 2026-08-01 crash left none on-box: journald lost
  # its final ~30s and efi-pstore stayed empty, which also means a plain
  # power/hardware reset stays indistinguishable from a panic. If netconsole
  # AND pstore are both empty after the next crash, it's hardware.
  #
  # netconsole needs raw L2 facts the fleet registry doesn't carry: the
  # receiver is taro's LAN address and NIC MAC (enp1s0, on-link from
  # enp95s0). Update here if taro's DHCP reservation or NIC ever changes.
  # The source IP is left blank so the module picks up enp95s0's current
  # address; `+` enables extended (non-truncated) messages. The receiving
  # end lives in hosts/taro/services/netconsole-receiver.nix.
  #
  # Loaded via a unit instead of boot.kernelModules because the module
  # binds enp95s0 at load time, so the interface has to be up first.
  systemd.services.netconsole = {
    description = "Stream kernel log to taro via netconsole";
    wantedBy = ["multi-user.target"];
    after = ["network-online.target"];
    wants = ["network-online.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.kmod}/bin/modprobe netconsole netconsole=+@/enp95s0,6666@192.168.7.171/00:e0:4c:56:27:82";
      ExecStop = "${pkgs.kmod}/bin/modprobe -r netconsole";
    };
  };
}
