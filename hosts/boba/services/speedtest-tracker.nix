{
  inputs,
  config,
  ...
}: let
  domain = config.homelab.published.speedtest.fqdn;
in {
  age.secrets.speedtest-tracker-app-key = {
    file = "${inputs.self}/secrets/speedtest-tracker-app-key.age";
    owner = "speedtest-tracker";
    group = "nginx";
  };

  services.speedtest-tracker = {
    enable = true;
    enableNginx = true;
    virtualHost = domain;
    settings = {
      APP_KEY_FILE = config.age.secrets.speedtest-tracker-app-key.path;
      DB_CONNECTION = "sqlite";
      SPEEDTEST_SCHEDULE = "0 */2 * * *";
      DISPLAY_TIMEZONE = "America/New_York";
      APP_TIMEZONE = "America/New_York";
      PUBLIC_DASHBOARD = true;
      PRUNE_RESULTS_OLDER_THAN = 1095;
    };
  };

  # enableNginx above generates the vhost body (php-fpm locations), so publishing
  # contributes only reachability and the certificate.
  homelab.published.speedtest.proxyTo = null;
}
