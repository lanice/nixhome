{pkgs, ...}: {
  # Receiving end of boba's netconsole stream (hosts/boba/netconsole.nix).
  # Kernel messages arrive as plain UDP datagrams; socat forwards each into
  # taro's journal, so boba's dying words survive boba:
  #   journalctl -u netconsole-receiver
  systemd.services.netconsole-receiver = {
    description = "Receive boba's netconsole kernel log";
    wantedBy = ["multi-user.target"];
    after = ["network-online.target"];
    wants = ["network-online.target"];
    serviceConfig = {
      ExecStart = "${pkgs.socat}/bin/socat -u UDP4-RECV:6666,reuseaddr STDOUT";
      Restart = "always";
      RestartSec = 5;
      DynamicUser = true;
    };
  };

  # LAN-only listener; nothing tailnet-side needs it.
  networking.firewall.interfaces.enp1s0.allowedUDPPorts = [6666];
}
