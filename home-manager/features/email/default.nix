{pkgs, ...}: {
  # programs.mbsync.enable = true;
  # programs.msmtp.enable = true;
  # programs.notmuch = {
  #   enable = true;
  #   hooks.preNew = "mbsync --all";
  # };
  # programs.neomutt.enable = true;
  programs.thunderbird = {
    enable = true;
    profiles.lanice = {
      isDefault = true;
      settings = {
        # "font.size.variable.x-western" = 16;
        "mailnews.default_sort_order" = 2; # descending order
        "mailnews.default_sort_type" = 18; # sort by date
        "privacy.donottrackheader.enabled" = true;
      };
    };
  };

  accounts.email = {
    maildirBasePath = "mail"; # not used by thunderbird

    accounts.gmail = {
      primary = true;
      address = "leanderneiss@gmail.com";
      flavor = "gmail.com";
      userName = "leanderneiss@gmail.com";
      realName = "Leander Neiß";
      # passwordCommand = "${pkgs.rbw}/bin/rbw get gmail-apppassword-leanderneiss";
      thunderbird.enable = true;
    };

    accounts.posteo = {
      primary = false;
      address = "neiss@posteo.de";
      userName = "neiss@posteo.de";
      realName = "Leander Neiß";
      # passwordCommand = "${pkgs.rbw}/bin/rbw get posteo.de";
      imap = {
        host = "posteo.de";
        port = 993;
      };
      smtp = {
        host = "posteo.de";
        port = 465;
      };
      thunderbird.enable = true;
    };

    accounts.gmx = {
      primary = false;
      address = "leander.neiss@gmx.de";
      userName = "leander.neiss@gmx.de";
      realName = "Leander Neiß";
      # passwordCommand = "${pkgs.rbw}/bin/rbw get 'GMX Email'";
      imap = {
        host = "imap.gmx.net";
        port = 993;
      };
      smtp = {
        host = "mail.gmx.net";
        port = 465;
      };
      thunderbird.enable = true;
    };

    accounts."web.de" = {
      primary = false;
      address = "leander_neiss@web.de";
      userName = "leander_neiss";
      realName = "Leander Neiß";
      # passwordCommand = "${pkgs.rbw}/bin/rbw get web.de";
      imap = {
        host = "imap.web.de";
        port = 993;
      };
      smtp = {
        host = "smtp.web.de";
        port = 465;
      };
      thunderbird.enable = true;
    };

    accounts.yahoo = {
      primary = false;
      address = "l.neiss@yahoo.de";
      userName = "l.neiss@yahoo.de";
      realName = "Leander Neiß";
      # passwordCommand = "${pkgs.rbw}/bin/rbw get yahoo-apppassword";
      imap = {
        host = "imap.mail.yahoo.com";
        port = 993;
      };
      smtp = {
        host = "smtp.mail.yahoo.com";
        port = 465;
      };
      thunderbird.enable = true;
    };

    accounts.ionos = {
      primary = false;
      address = "me@leanderneiss.de";
      userName = "me@leanderneiss.de";
      realName = "Leander Neiß";
      imap = {
        host = "imap.ionos.de";
        port = 993;
      };
      smtp = {
        host = "smtp.ionos.de";
        port = 465;
      };
      thunderbird.enable = true;
    };
  };
}
