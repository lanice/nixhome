# The archive's only access channel: Roundcube at archive.lanice.dev, over the
# tailnet (Dovecot listens on localhost only).
#
# Read-only is enforced by the ACL in mail-archive.nix; disabled_actions below
# just stops the UI offering writes the server would refuse.
{
  config,
  lib,
  ...
}: let
  pub = config.homelab.published.archive;

  # Matched against a button's command and against '<task>.<command>'; bare
  # names because most appear in more than one task. Compose/reply/forward go
  # too: taro runs no submission service, so a reply would be a dead end.
  disabledActions = [
    "compose"
    "compose-encrypted"
    "compose-encrypted-signed"
    "reply"
    "reply-all"
    "reply-list"
    "forward"
    "forward-inline"
    "forward-attachment"
    "bounce"
    "edit"
    "delete"
    "move"
    "copy"
    "purge"
    "expunge"
    "mark"
    "mark-all-read"
    # disabled_actions matches `command=`, which is `import-messages`;
    # "import" (the button's label and class) leaves the button on the page.
    "import-messages"
    # Folder management would offer to create and delete trees; identities and
    # responses only exist to send mail with.
    "settings.folders"
    "settings.identities"
    "settings.responses"
  ];

  phpList = items: "[${lib.concatMapStringsSep ", " (item: "'${item}'") items}]";
in {
  services.roundcube = {
    enable = true;
    hostName = pub.fqdn;

    extraConfig = ''
      $config['imap_host'] = 'localhost:143';
      $config['imap_delimiter'] = '/';

      // Dovecot's ACL plugin taxes IMAP LIST at ~25 ms per visible folder
      // (5.3 s for 209), and Roundcube LISTs the full namespace on every
      // click. Cache the folder list; on the db backend the TTL is not
      // enforced on read, so the cache lives until the next login clears
      // it — new nightly folders appear on re-login, accepted for an
      // archive. LSUB skips the ACL tax (105 ms for the same 209), which
      // covers the uncached LIST each login still pays; Roundcube adds
      // INBOX to the pane itself, so its unsubscribed state is harmless.
      $config['imap_cache'] = 'db';
      $config['imap_force_lsub'] = true;

      $config['product_name'] = 'Mail archive';
      $config['disabled_actions'] = ${phpList disabledActions};

      // The archive holds many accounts side by side, so there is no one Sent
      // or Trash to point at; empty stops Roundcube creating them. Double
      // quotes: an empty PHP single-quoted string would close this Nix string.
      $config['drafts_mbox'] = "";
      $config['junk_mbox'] = "";
      $config['sent_mbox'] = "";
      $config['trash_mbox'] = "";
      $config['create_default_folders'] = false;
    '';
  };

  # The roundcube module generates the vhost body itself (php-fpm locations),
  # so publishing contributes only reachability and the certificate.
  homelab.published.archive.proxyTo = null;
}
