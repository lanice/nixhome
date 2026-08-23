let
  fleet = import ../hosts/fleet.nix;
  inherit (fleet.users) lanice-sencha lanice-unstable;

  unstable = fleet.hosts.unstable.hostKey;
  sencha = fleet.hosts.sencha.hostKey;
  boba = fleet.hosts.boba.hostKey;
  taro = fleet.hosts.taro.hostKey;
in {
  "porkbun.age".publicKeys = [unstable boba taro lanice-unstable lanice-sencha];
  "porkbunApiKey.age".publicKeys = [boba lanice-sencha];
  "porkbunSecretApiKey.age".publicKeys = [boba lanice-sencha];
  "homepage.age".publicKeys = [boba lanice-sencha];
  "librechat.env.age".publicKeys = [boba lanice-sencha];
  "mailBobaPassword.age".publicKeys = [boba lanice-sencha];
  "sabnzbd.age".publicKeys = [boba lanice-sencha];
  "shelfmark.age".publicKeys = [boba lanice-sencha];
  "bookorbit.age".publicKeys = [boba lanice-sencha];
  "slskd.age".publicKeys = [boba lanice-sencha];
  "healthcheck-uuid.age".publicKeys = [boba lanice-sencha];
  "peertube-secrets.age".publicKeys = [boba lanice-sencha];
  "peertube-db-password.age".publicKeys = [boba lanice-sencha];
  "explo.age".publicKeys = [boba lanice-sencha];
  "speedtest-tracker-app-key.age".publicKeys = [boba lanice-sencha];
  "forgejo-runner-token.age".publicKeys = [boba lanice-sencha];
  "resticB2Credentials.age".publicKeys = [boba lanice-sencha];
  "resticOffsiteHealthcheckUuid.age".publicKeys = [boba lanice-sencha];
  "resticSenchaHealthcheckUuid.age".publicKeys = [sencha lanice-sencha];
  "resticMonthlyHealthcheckUuid.age".publicKeys = [boba lanice-sencha];
  "resticHtpasswd.age".publicKeys = [boba lanice-sencha];
  "resticSenchaTransport.age".publicKeys = [sencha lanice-sencha];
  "resticForgejoTransport.age".publicKeys = [taro lanice-sencha];
  "resticMailArchiveTransport.age".publicKeys = [taro lanice-sencha];
  "resticBobaTransport.age".publicKeys = [boba lanice-sencha];
  "resticSenchaPassword.age".publicKeys = [sencha boba lanice-sencha];
  "resticForgejoPassword.age".publicKeys = [taro boba lanice-sencha];
  "resticBobaPassword.age".publicKeys = [boba lanice-sencha];
  "resticOffsiteSenchaPassword.age".publicKeys = [boba lanice-sencha];
  "resticOffsiteForgejoPassword.age".publicKeys = [boba lanice-sencha];
  "resticOffsiteMailArchivePassword.age".publicKeys = [boba lanice-sencha];
  "resticOffsiteBobaPassword.age".publicKeys = [boba lanice-sencha];
  "forgejo-dump-key.age".publicKeys = [taro lanice-sencha];
  "mailTaroPassword.age".publicKeys = [taro lanice-sencha];
  "mailArchiveUsers.age".publicKeys = [taro lanice-sencha];
  "mailArchiveSyncPassword.age".publicKeys = [taro lanice-sencha];
  "mailSourcePasswords.age".publicKeys = [taro lanice-sencha];
  "mailArchiveResticPassword.age".publicKeys = [taro boba lanice-sencha];
  "mailArchiveHealthcheckUuid.age".publicKeys = [taro lanice-sencha];
}
