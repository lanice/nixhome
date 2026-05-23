{
  services.scrutiny = {
    enable = true;
    settings.web = {
      listen = {
        port = 8082;
        host = "127.0.0.1";
      };
      influxdb.host = "127.0.0.1";
    };
    collector = {
      enable = true;
      schedule = "*-*-* 06:00:00";
    };
  };
}
