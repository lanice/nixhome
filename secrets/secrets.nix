let
  fleet = import ../hosts/fleet.nix;
  inherit (fleet.users) lanice-sencha lanice-unstable;

  unstable = fleet.hosts.unstable.hostKey;
  boba = fleet.hosts.boba.hostKey;
  taro = fleet.hosts.taro.hostKey;
in {
  "porkbun.age".publicKeys = [unstable boba taro lanice-unstable lanice-sencha];
  "porkbunApiKey.age".publicKeys = [boba lanice-sencha];
  "porkbunSecretApiKey.age".publicKeys = [boba lanice-sencha];
  "homepage.age".publicKeys = [boba lanice-sencha];
  "librechat.env.age".publicKeys = [boba lanice-sencha];
  "curseforge.age".publicKeys = [boba lanice-sencha];
  "mailBobaPassword.age".publicKeys = [boba lanice-sencha];
  "sabnzbd.age".publicKeys = [boba lanice-sencha];
  "shelfmark.age".publicKeys = [boba lanice-sencha];
  "bookorbit.age".publicKeys = [boba lanice-sencha];
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
