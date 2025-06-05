{
  services.adguardhome = {
    enable = true;
    mutableSettings = true;
    port = 3003;
    settings = {
      users = [
        {
          name = "admin";
          password = "$2a$10$rlVySi8hCUDInWuv62lkF.pbfYOf.2njwVZc17AH2dWMX6vd6F7AO";
        }
      ];
      dns = {
        bind_hosts = ["0.0.0.0"];
        port = 5353;
      };
    };
  };
}
