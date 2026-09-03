# Fleet registry (see CONTEXT.md): per-host tailnet identity, Syncthing
# device IDs and people's public keys, written once. Pure data — secrets.nix
# imports it outside the module system, so no module args here.
{
  hosts = {
    sencha = {
      hostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAv3szAVxIFqWKFoF7z+97k/nRCN/1VW0nD75EHGzbKQ root@sencha";
      syncthingId = "4BN4A3S-EUA2SVD-QNEJHI6-LJKBVWW-7FV4YRE-5YOIQBR-A4CWZLB-OQLGBA6";
    };
    boba = {
      tailscaleIP = "100.124.185.117";
      hostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGMTGnHrTZedzzB7ssfr0yjPTrIpL4g19Yzi/46dVBdt root@boba";
      syncthingId = "DGY5HLA-TIKZI6X-BNMZULZ-PHPMCJH-L57RGVV-TGEKYH3-7VISX5L-W4KYOQL";
    };
    taro = {
      tailscaleIP = "100.103.16.7";
      hostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPO3sR4EqTuRnLGqntiXcwQrMboukQB/1kEUrz2yBdM7 root@taro";
    };
    # No tailscaleIP: unstable's nginx.nix keeps its own literal.
    unstable = {
      hostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGrqPXr49t/nDW8UtCjPVkmIW8qpHCnsYLjnZWYx7vED root@unstable";
      syncthingId = "ZSOKQGJ-K55JPO2-W4N75YJ-6NJI64R-HLQTT72-JENBU3L-DU44IG5-BVHIXAS";
    };
    # No sshd yet, so no hostKey (hosts/longjing/default.nix).
    longjing = {
      syncthingId = "5JEE5H6-VNV7EFN-OFUK3YC-ID2B4W2-KDVP4O7-DDUI6GJ-D7STGCF-BT6VKA3";
    };
  };

  # Syncthing peers outside the fleet: devices this flake does not manage but
  # that fleet hosts sync with.
  devices = {
    SunsetDragon.syncthingId = "GQWATA7-Y6EUELT-HZYCAOU-O6AMUID-YIU4AYD-O7QT3V4-ZUE4ZP7-LIITDAE";
    S23Ultra.syncthingId = "IO377ZW-XGOPD22-O6N6B4F-WQJYEYF-2GE463X-DH7MY4M-ZZEQ5CN-T2HJTAC";
  };

  users = {
    lanice-sencha = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGwdc+uAZvNnh7OTdtIT1ei1n/S+jZdYBZlDXNkNouo2 lanice@sencha";
    lanice-unstable = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHr1ModaOEBmMoP4IhJim4Uorgg8KIz7pfSPEWzVk1aq lanice@unstable";
    lanice-longjing = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEt3cdjFpGUfLo47pun2HmJo9zGeOjGD+1fBXOJciMXN lanice@longjing";
    juicessh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICgsgaiVXnUCumEl99kkvf7xYpik5jCryuo4gsrxztKn JuiceSSH";
  };
}
