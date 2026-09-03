# Fleet registry (see CONTEXT.md): per-host tailnet identity and people's
# public keys, written once. Pure data — secrets.nix imports it outside the
# module system, so no module args here.
{
  hosts = {
    sencha = {
      hostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAv3szAVxIFqWKFoF7z+97k/nRCN/1VW0nD75EHGzbKQ root@sencha";
    };
    boba = {
      tailscaleIP = "100.124.185.117";
      hostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGMTGnHrTZedzzB7ssfr0yjPTrIpL4g19Yzi/46dVBdt root@boba";
    };
    taro = {
      tailscaleIP = "100.103.16.7";
      hostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPO3sR4EqTuRnLGqntiXcwQrMboukQB/1kEUrz2yBdM7 root@taro";
    };
    # No tailscaleIP: unstable's nginx.nix keeps its own literal.
    unstable = {
      hostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGrqPXr49t/nDW8UtCjPVkmIW8qpHCnsYLjnZWYx7vED root@unstable";
    };
  };

  users = {
    lanice-sencha = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGwdc+uAZvNnh7OTdtIT1ei1n/S+jZdYBZlDXNkNouo2 lanice@sencha";
    lanice-unstable = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHr1ModaOEBmMoP4IhJim4Uorgg8KIz7pfSPEWzVk1aq lanice@unstable";
    lanice-longjing = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEt3cdjFpGUfLo47pun2HmJo9zGeOjGD+1fBXOJciMXN lanice@longjing";
    juicessh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICgsgaiVXnUCumEl99kkvf7xYpik5jCryuo4gsrxztKn JuiceSSH";
  };
}
