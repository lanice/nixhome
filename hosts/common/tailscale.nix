{
  config,
  pkgs,
  ...
}: {
  # enable the tailscale daemon; this will do a variety of tasks:
  # 1. create the TUN network device
  # 2. setup some IP routes to route through the TUN
  services.tailscale = {enable = true;};

  # Let's open the UDP port with which the network is tunneled through
  # networking.firewall.allowedUDPPorts = [ 41641 ];
  # networking.firewall.checkReversePath = "loose";

  # Disable SSH access through the firewall
  # Only way into the machine will be through
  # This may cause a chicken & egg problem since you need to register a machine
  # first using `tailscale up`
  # Better to rely on EC2 SecurityGroups
  # services.openssh.openFirewall = false;

  # Let's make the tailscale binary available to all users
  environment.systemPackages = [pkgs.tailscale];

  networking.firewall = {
    # enable the firewall
    enable = true;

    # always allow traffic from your Tailscale network
    trustedInterfaces = ["tailscale0"];

    # allow the Tailscale UDP port through the firewall
    allowedUDPPorts = [config.services.tailscale.port];

    # allow you to SSH in over the public internet
    allowedTCPPorts = [22];
  };
}
