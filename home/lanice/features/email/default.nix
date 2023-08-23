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
        # "mailnews.database.global.views.conversation.columns" = "{\"selectCol\":{\"visible\":false,\"ordinal\":\"1\"},\"threadCol\":{\"visible\":true,\"ordinal\":\"3\"},\"flaggedCol\":{\"visible\":true,\"ordinal\":\"5\"},\"attachmentCol\":{\"visible\":false,\"ordinal\":\"7\"},\"subjectCol\":{\"visible\":true,\"ordinal\":\"9\"},\"unreadButtonColHeader\":{\"visible\":false,\"ordinal\":\"11\"},\"senderCol\":{\"visible\":false,\"ordinal\":\"13\"},\"recipientCol\":{\"visible\":false,\"ordinal\":\"15\"},\"correspondentCol\":{\"visible\":true,\"ordinal\":\"17\"},\"junkStatusCol\":{\"visible\":false,\"ordinal\":\"19\"},\"receivedCol\":{\"visible\":false,\"ordinal\":\"21\"},\"dateCol\":{\"visible\":true,\"ordinal\":\"23\"},\"statusCol\":{\"visible\":false,\"ordinal\":\"25\"},\"sizeCol\":{\"visible\":false,\"ordinal\":\"27\"},\"tagsCol\":{\"visible\":false,\"ordinal\":\"29\"},\"accountCol\":{\"visible\":true,\"ordinal\":\"31\"},\"priorityCol\":{\"visible\":false,\"ordinal\":\"33\"},\"unreadCol\":{\"visible\":false,\"ordinal\":\"35\"},\"totalCol\":{\"visible\":false,\"ordinal\":\"37\"},\"locationCol\":{\"visible\":true,\"ordinal\":\"39\"},\"idCol\":{\"visible\":false,\"ordinal\":\"41\"},\"deleteCol\":{\"visible\":false,\"ordinal\":\"43\"}}";
        # "mailnews.database.global.views.global.columns" = "{\"selectCol\":{\"visible\":false,\"ordinal\":\"1\"},\"threadCol\":{\"visible\":true,\"ordinal\":\"3\"},\"flaggedCol\":{\"visible\":true,\"ordinal\":\"5\"},\"attachmentCol\":{\"visible\":false,\"ordinal\":\"7\"},\"subjectCol\":{\"visible\":true,\"ordinal\":\"9\"},\"unreadButtonColHeader\":{\"visible\":false,\"ordinal\":\"11\"},\"senderCol\":{\"visible\":false,\"ordinal\":\"13\"},\"recipientCol\":{\"visible\":false,\"ordinal\":\"15\"},\"correspondentCol\":{\"visible\":true,\"ordinal\":\"17\"},\"junkStatusCol\":{\"visible\":false,\"ordinal\":\"19\"},\"receivedCol\":{\"visible\":false,\"ordinal\":\"21\"},\"dateCol\":{\"visible\":true,\"ordinal\":\"23\"},\"statusCol\":{\"visible\":false,\"ordinal\":\"25\"},\"sizeCol\":{\"visible\":false,\"ordinal\":\"27\"},\"tagsCol\":{\"visible\":false,\"ordinal\":\"29\"},\"accountCol\":{\"visible\":true,\"ordinal\":\"31\"},\"priorityCol\":{\"visible\":false,\"ordinal\":\"33\"},\"unreadCol\":{\"visible\":false,\"ordinal\":\"35\"},\"totalCol\":{\"visible\":false,\"ordinal\":\"37\"},\"locationCol\":{\"visible\":true,\"ordinal\":\"39\"},\"idCol\":{\"visible\":false,\"ordinal\":\"41\"},\"deleteCol\":{\"visible\":false,\"ordinal\":\"43\"}}";
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

    accounts.founderbuddies = {
      primary = false;
      address = "info@founderbuddies.com";
      userName = "info@founderbuddies.com";
      realName = "Founder Buddies";
      imap = {
        host = "eagle.mxlogin.com";
        port = 993;
      };
      smtp = {
        host = "eagle.mxlogin.com";
        port = 465;
      };
      thunderbird.enable = true;
    };

    accounts.leanderneiss = {
      primary = false;
      address = "me@leanderneiss.com";
      userName = "me@leanderneiss.com";
      realName = "Leander Neiss";
      imap = {
        host = "witcher.mxrouting.net";
        port = 993;
      };
      smtp = {
        host = "witcher.mxrouting.net";
        port = 465;
      };
      thunderbird.enable = true;
    };
  };
}
