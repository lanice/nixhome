{
  inputs,
  config,
  ...
}: let
  user = "sabnzbd";
  mediaGroup = "multimedia";
  downloadDir = "/downloads/usenet";
in {
  age.secrets.sabnzbd = {
    file = "${inputs.self}/secrets/sabnzbd.age";
    owner = user;
    group = mediaGroup;
    mode = "770";
  };

  services.sabnzbd = {
    enable = true;
    user = user;
    group = mediaGroup;
    allowConfigWrite = true;
    secretFiles = [config.age.secrets.sabnzbd.path];
    settings = {
      misc = {
        host_whitelist = "sabnzbd.lanice.dev";
        port = 8080;
        download_dir = "${downloadDir}/incomplete";
        complete_dir = "${downloadDir}/complete";
        permissions = "770";
        admin_dir = "admin";
        backup_dir = "backups";
        cache_limit = "2G";
      };
      servers = {
        "news.newsdemon.com" = {
          name = "news.newsdemon.com";
          displayname = "Newsdemon";
          host = "news.newsdemon.com";
          priority = 0;
          port = 563;
          connections = 42;
          ssl = true;
          ssl_verify = 3;
          enable = true;
          expire_date = "2026-09-29";
        };
        "news.newshosting.com" = {
          name = "news.newshosting.com";
          displayname = "Newshosting";
          host = "news.newshosting.com";
          priority = 1;
          port = 563;
          connections = 30;
          ssl = true;
          ssl_verify = 3;
          enable = true;
          expire_date = "2026-04-01";
        };
        "eunews.blocknews.net" = {
          name = "eunews.blocknews.net";
          displayname = "Blocknews";
          host = "eunews.blocknews.net";
          priority = 99;
          port = 563;
          connections = 8;
          ssl = true;
          ssl_verify = 3;
          enable = true;
          quota = "700G";
          usage_at_start = 105528735247;
        };
      };
      categories = {
        "*" = {
          name = "*";
          order = 0;
          pp = 3;
          script = "None";
          dir = "";
          newzbin = "";
          priority = 0;
        };
        "movies" = {
          name = "movies";
          order = 1;
          pp = "";
          script = "Default";
          dir = "";
          newzbin = "";
          priority = -100;
        };
        "tv" = {
          name = "tv";
          order = 2;
          pp = "";
          script = "Default";
          dir = "";
          newzbin = "";
          priority = -100;
        };
        "audio" = {
          name = "audio";
          order = 3;
          pp = "";
          script = "Default";
          dir = "";
          newzbin = "";
          priority = -100;
        };
        "software" = {
          name = "software";
          order = 4;
          pp = "";
          script = "Default";
          dir = "";
          newzbin = "";
          priority = -100;
        };
        "ebooks" = {
          name = "ebooks";
          order = 5;
          pp = "";
          script = "Default";
          dir = "";
          newzbin = "";
          priority = -100;
        };
        "bookshelf" = {
          name = "bookshelf";
          order = 6;
          pp = "";
          script = "Default";
          dir = "";
          newzbin = "";
          priority = -100;
        };
      };
    };
  };
}
