{...}: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "github.com" = {
        IdentityFile = "~/.ssh/id_ed25519";
        IdentitiesOnly = "yes";
      };
      # Colmena targets `unstable`; its tailnet name is stable-diffusion.
      unstable.HostName = "stable-diffusion";
    };
  };
}
