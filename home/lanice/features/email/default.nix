{
  inputs,
  lib,
  ...
}: let
  # Server presets, keyed by the `provider` field of the private records.
  providers = {
    gmail = {
      flavor = "gmail.com";
      thunderbird.settings = id: {
        "mail.smtpserver.smtp_${id}.authMethod" = 10; # oauth
      };
    };
    posteo = {
      imap = {
        host = "posteo.de";
        port = 993;
      };
      smtp = {
        host = "posteo.de";
        port = 465;
      };
    };
    gmx = {
      imap = {
        host = "imap.gmx.net";
        port = 993;
      };
      smtp = {
        host = "mail.gmx.net";
        port = 465;
      };
    };
    "web.de" = {
      imap = {
        host = "imap.web.de";
        port = 993;
      };
      smtp = {
        host = "smtp.web.de";
        port = 465;
      };
    };
    yahoo = {
      imap = {
        host = "imap.mail.yahoo.com";
        port = 993;
      };
      smtp = {
        host = "smtp.mail.yahoo.com";
        port = 465;
      };
    };
    mxlogin = {
      imap = {
        host = "eagle.mxlogin.com";
        port = 993;
      };
      smtp = {
        host = "eagle.mxlogin.com";
        port = 465;
      };
    };
    mxroute = {
      imap = {
        host = "witcher.mxrouting.net";
        port = 993;
      };
      smtp = {
        host = "witcher.mxrouting.net";
        port = 465;
      };
    };
  };

  # recursiveUpdate, not //: a shallow merge of thunderbird.enable would
  # clobber the gmail preset's thunderbird.settings.
  mkAccount = _name: acct:
    lib.recursiveUpdate providers.${acct.provider} {
      inherit (acct) address realName;
      userName = acct.userName or acct.address;
      primary = acct.primary or false;
      thunderbird.enable = true;
    };
in {
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
        "mail.identity.default.reply_on_top" = 1;
        "mail.identity.default.sig_bottom" = false;
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

    # Addresses, names, and account keys live in the private input; this
    # module only contributes the structure above.
    accounts = lib.mapAttrs mkAccount (import (inputs.nixhome-private + "/workstation-email.nix"));
  };
}
