# Workstation-side trust for the fleet: host keys from the registry, so no
# trust-on-first-use prompt on a fresh machine.
{...}: let
  fleet = import ../fleet.nix;
in {
  programs.ssh.knownHosts = {
    sencha.publicKey = fleet.hosts.sencha.hostKey;
    boba = {
      hostNames = ["boba" fleet.hosts.boba.tailscaleIP];
      publicKey = fleet.hosts.boba.hostKey;
    };
    taro = {
      hostNames = ["taro" fleet.hosts.taro.tailscaleIP];
      publicKey = fleet.hosts.taro.hostKey;
    };
    # unstable's tailnet name is stable-diffusion; ssh.nix aliases it.
    unstable = {
      hostNames = ["stable-diffusion"];
      publicKey = fleet.hosts.unstable.hostKey;
    };
  };
}
