# https://wiki.nixos.org/wiki/ZFS#Mail_notifications_(ZFS_Event_Daemon)
{
  inputs,
  pkgs,
  config,
  ...
}: {
  age.secrets.mailBobaPassword.file = "${inputs.self}/secrets/mailBobaPassword.age";

  programs.msmtp = {
    enable = true;
    setSendmail = true;
    defaults = {
      aliases = "/etc/aliases";
      port = 465;
      tls_trust_file = "/etc/ssl/certs/ca-certificates.crt";
      tls = "on";
      auth = "login";
      tls_starttls = "off";
    };
    accounts = {
      default = {
        host = "witcher.mxrouting.net";
        user = "boba@lanice.dev";
        from = "boba@lanice.dev";
        passwordeval = "${pkgs.coreutils}/bin/cat ${config.age.secrets.mailBobaPassword.path}";
      };
    };
  };

  environment.etc.aliases.text = ''
    root: leanderneiss@gmail.com
  '';

  services.zfs.zed.settings = {
    ZED_DEBUG_LOG = "/tmp/zed.debug.log";
    ZED_EMAIL_ADDR = ["root"];
    ZED_EMAIL_PROG = "${pkgs.msmtp}/bin/msmtp";
    ZED_EMAIL_OPTS = "@ADDRESS@";

    ZED_NOTIFY_INTERVAL_SECS = 3600;
    ZED_NOTIFY_VERBOSE = true;

    ZED_USE_ENCLOSURE_LEDS = true;
    ZED_SCRUB_AFTER_RESILVER = true;
  };

  # this option does not work; will return error
  services.zfs.zed.enableMail = false;
}
