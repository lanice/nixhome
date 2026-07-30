let
  lanice-sencha = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGwdc+uAZvNnh7OTdtIT1ei1n/S+jZdYBZlDXNkNouo2 lanice@sencha";
  lanice-unstable = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHr1ModaOEBmMoP4IhJim4Uorgg8KIz7pfSPEWzVk1aq lanice@unstable";

  unstable = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGrqPXr49t/nDW8UtCjPVkmIW8qpHCnsYLjnZWYx7vED root@unstable";
  boba = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGMTGnHrTZedzzB7ssfr0yjPTrIpL4g19Yzi/46dVBdt root@boba";
  taro = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPO3sR4EqTuRnLGqntiXcwQrMboukQB/1kEUrz2yBdM7 root@taro";
in {
  "porkbun.age".publicKeys = [unstable boba taro lanice-unstable lanice-sencha];
  "porkbunApiKey.age".publicKeys = [boba lanice-sencha];
  "porkbunSecretApiKey.age".publicKeys = [boba lanice-sencha];
  "homepage.age".publicKeys = [boba lanice-sencha];
  "librechat.env.age".publicKeys = [boba lanice-sencha];
  "curseforge.age".publicKeys = [boba lanice-sencha];
  "mailBobaPassword.age".publicKeys = [boba lanice-sencha];
  "sabnzbd.age".publicKeys = [boba lanice-sencha];
  "slskd.age".publicKeys = [boba lanice-sencha];
  "healthcheck-uuid.age".publicKeys = [boba lanice-sencha];
  "healthcheck-minecraft-uuid.age".publicKeys = [boba lanice-sencha];
  "peertube-secrets.age".publicKeys = [boba lanice-sencha];
  "peertube-db-password.age".publicKeys = [boba lanice-sencha];
  "explo.age".publicKeys = [boba lanice-sencha];
  "speedtest-tracker-app-key.age".publicKeys = [boba lanice-sencha];
  "forgejo-runner-token.age".publicKeys = [boba lanice-sencha];
  "forgejo-dump-key.age".publicKeys = [taro lanice-sencha];
}
