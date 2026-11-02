{inputs, ...}: let
  # Same identity as the tailnet login.
  login = "tailscale:${(import (inputs.nixhome-private + "/contacts.nix")).admin}";
in {
  imports = [inputs.rex.nixosModules.default];

  # Serves on tailnet port 7297; nginx keeps 443.
  services.rex.loginServer = {
    enable = true;
    accounts.coding.principals = [login];
    defaults.${login} = "coding";
    tailscaleServe.enable = true;
  };
}
