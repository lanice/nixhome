# The mail archive's store: one Dovecot tree per source account, named by flat
# full address (hi@example.com/INBOX), readable by the people it is granted to
# and writable by nobody. Spec: .scratch/mail-archive/spec.md. Vocabulary:
# CONTEXT.md § Mail archive.
#
# One *public* namespace, load-bearing: a private namespace's owner bypasses
# ACLs, so read-only could not be enforced; public has no owner, so the ACL is
# the whole truth for every login.
{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.homelab.mailArchive;

  persons = ["ln" "af"];

  # The only login allowed to write; the mirror passes authenticate as this.
  syncUser = "archive-sync";

  storeDir = "/var/lib/mail-archive";

  # IMAP insists every account has an INBOX; the archive has no use for it.
  # Outside the store so it can never show up as a source account tree.
  personHomes = "/var/lib/dovecot/persons";

  # Dovecot spells ACL rights as single letters:
  #   l lookup   r read      s write-seen  w write-flags  i insert
  #   p post     k create    x delete-box  t write-deleted
  #   e expunge  a administer (change the ACL itself)
  rights = {
    # Not even marking a message read, which is why clients open these
    # mailboxes READ-ONLY and a stray delete is refused by the server.
    read = "lr";

    # Everything except `a`: pruning needs t+e, rewriting the ACL from a mail
    # client never does.
    curation = "lrwstipekx";

    # Enough to create folders and copy mail in, and deliberately no `t`, `e`
    # or `x`: a mirror pass that somehow grew a `--delete2` still could not
    # remove anything.
    sync = "lrswik";
  };

  personRights =
    if cfg.curation
    then rights.curation
    else rights.read;

  # One account's grant in the vfile backend's format; treesPass writes it into
  # every mailbox of the tree. Files rather than dovecot.conf: folder creation
  # probes the parent and caches an empty rights entry only a stat()able ACL
  # file can refresh — conf-only ends every mirror pass in "Permission denied".
  # And ACLs don't inherit at read time (Dovecot copies the parent's at
  # creation), which is also why treesPass rewrites whole trees: a revoked
  # grant has to reach folders created under the old one.
  aclFile = address: account:
    pkgs.writeText "dovecot-acl-${address}" (
      lib.concatMapStrings (person: "user=${person} ${personRights}\n") account.grantedTo
      + "user=${syncUser} ${rights.sync}\n"
    );

  # Declaring an account is what brings its tree into being: `auto` is the one
  # way a top-level mailbox can appear, because creating one writes to the
  # namespace root and no login holds rights there. Enrolment therefore only
  # ever happens by deploying, never at runtime.
  #
  # `subscribe` rather than `create` because Roundcube lists subscribed folders
  # only (see the subscriptions note on the namespace below).
  accountSettings = address: _account: {
    ${''mailbox "${address}"''}.auto = "subscribe";
  };

  # One pass over the store, shared by mail-archive-trees (each deploy) and
  # mail-archive-trees-refresh (each night). Per account: force the tree into
  # existence via `mailbox status` (`auto` is lazy; a listing doesn't open the
  # mailbox), grant the tree root before any listing (`mailbox list` is
  # ACL-filtered even for the sync identity and a just-born tree has no ACL
  # file; `mailbox path` computes the path without a lookup), grant every
  # folder below, subscribe everything for Roundcube. Paths via `doveadm
  # mailbox path`: on disk a non-ASCII name is mUTF-7 (`Gel&APY-scht`).
  treesPass = let
    doveadm = lib.getExe' config.services.dovecot2.package "doveadm";
  in
    lib.concatStrings (lib.mapAttrsToList (address: account: let
        quoted = lib.escapeShellArg address;
      in ''
        ${doveadm} mailbox status -u ${syncUser} messages -- ${quoted}

        ${pkgs.coreutils}/bin/install -o vmail -g vmail -m 0600 \
          ${aclFile address account} \
          "$(${doveadm} mailbox path -u ${syncUser} -- ${quoted})/dovecot-acl"

        mailboxes=$(${doveadm} mailbox list -u ${syncUser} -- ${quoted} ${quoted}/'*')

        # doveadm panics on an empty mailbox name and the install below would
        # land its ACL file at the filesystem root. After the bootstrap above,
        # an empty listing can only mean that bootstrap regressed.
        if [ -z "$mailboxes" ]; then
          printf 'no mailboxes listed for %s after its root ACL was installed\n' ${quoted} >&2
          exit 1
        fi

        printf '%s\n' "$mailboxes" |
          while IFS= read -r mailbox; do
            ${pkgs.coreutils}/bin/install -o vmail -g vmail -m 0600 \
              ${aclFile address account} \
              "$(${doveadm} mailbox path -u ${syncUser} -- "$mailbox")/dovecot-acl"
          done

        printf '%s\n' "$mailboxes" |
          ${pkgs.findutils}/bin/xargs -d '\n' -r \
            ${doveadm} mailbox subscribe -u ${syncUser} --
      '')
      cfg.accounts);

  accountModule = {
    options = {
      host = lib.mkOption {
        type = lib.types.str;
        example = "eagle.mxlogin.com";
        description = ''
          IMAP server the source account lives on. Read by the mirror pass;
          the store itself never contacts it.
        '';
      };

      grantedTo = lib.mkOption {
        type = lib.types.listOf (lib.types.enum persons);
        example = ["ln" "af"];
        description = ''
          The people who may read this account's tree. Naming both is how mail
          is shared — there is no other sharing mechanism.
        '';
      };
    };
  };
in {
  options.homelab.mailArchive = {
    accounts = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule accountModule);
      default = {};
      example = lib.literalExpression ''
        {
          "hi@example.com" = {
            host = "eagle.mxlogin.com";
            grantedTo = ["ln"];
          };
        }
      '';
      description = ''
        Source accounts the archive holds, keyed by full address.

        This attrset is the enrolment list: an account absent from it has no
        tree, cannot be given one at runtime, and is never mirrored.
      '';
    };

    curation = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Temporarily widen every person's ACL from read-only to read-write so
        that mail can be pruned by hand.

        The flip-switch: set true, deploy, prune from a mail client or doveadm,
        set false, deploy again. It is never a steady state — after a reclaim
        pass the archive is the only copy of the mail it holds.
      '';
    };
  };

  config = {
    warnings = lib.optional cfg.curation ''
      homelab.mailArchive.curation is on: the mail archive is writable by
      ${lib.concatStringsSep " and " persons}. Flip it back off once the
      pruning is done.
    '';

    # One passwd-file for all three logins. The sync password is also kept in
    # plaintext as mailArchiveSyncPassword for imapsync; regenerate both together.
    age.secrets.mailArchiveUsers = {
      file = "${inputs.self}/secrets/mailArchiveUsers.age";
      owner = config.services.dovecot2.settings.default_internal_user;
      mode = "400";
    };

    systemd.tmpfiles.rules = [
      "d ${storeDir} 0700 vmail vmail -"
      "d ${personHomes} 0700 vmail vmail -"
    ];

    services.dovecot2 = {
      enable = true;

      settings = {
        # Pinned rather than tracking the package, so a bump is a deliberate
        # read of the 2.4 upgrade notes and not a silent config rewrite.
        dovecot_config_version = "2.4.4";
        dovecot_storage_version = "2.4.4";

        protocols.imap = true;

        # No TLS: nothing off-host can reach the listener. Cleartext auth is
        # allowed on 127.0.0.1 regardless of auth_allow_cleartext, which is why
        # Roundcube can log in over loopback.
        ssl = false;

        mail_uid = "vmail";
        mail_gid = "vmail";

        # Maildir keeps one plain file per message — the format most likely to
        # still be readable if Dovecot is ever gone. `fs` layout is what allows
        # a '.' in a mailbox name; the Maildir++ default steals '.' as its
        # hierarchy separator, ruling out trees named after email addresses.
        mail_driver = "maildir";
        mailbox_list_layout = "fs";
        mail_home = "${personHomes}/%{user}";
        mail_path = "~/mail";

        mail_plugins = {
          acl = true;
          fts = true;
          fts_flatcurve = true;
        };
        acl_driver = "vfile";

        # flatcurve is Dovecot 2.4's built-in Xapian backend; the fts_xapian
        # plugin it replaces is gone from nixpkgs.
        #
        # The empty block is not a placeholder: 2.4 turns FTS on by the
        # *presence* of a named `fts` filter, and the name is the driver.
        # `fts_driver = flatcurve` alone leaves the plugin loaded but inert —
        # one debug line ("No fts { .. } named list filter - plugin disabled")
        # while every body search quietly falls back to reading each message.
        #
        # Indexes live beside the mail: one index for the whole archive rather
        # than one per login.
        "fts flatcurve" = {};

        # Index as mail arrives: a mirror pass appends thousands of messages,
        # and the first search after it would otherwise pay for all of them.
        fts_autoindex = true;

        # Mandatory in 2.4 — Dovecot refuses to start without a language block.
        #
        # No `snowball` (which most flatcurve examples use): this build lacks
        # libstemmer, so it fails at plugin init. normalizer-icu folds case and
        # accents ("fruhstuck" finds "Frühstück"; 'ß' is a letter and stays).
        #
        # Ordered strings, not attrsets of booleans — an attrset renders
        # alphabetically, and `email-address generic` indexed every message as
        # a zero-term document: no error, healthy indexer logs, every body
        # search empty.
        "language en" = {
          language_default = true;
          language_filters = "normalizer-icu stopwords";
          language_tokenizers = "generic email-address";
        };

        "passdb passwd-file".passwd_file_path = config.age.secrets.mailArchiveUsers.path;
        # Every login gets the same uid/gid/home shape, so the passwd-file
        # carries passwords only.
        "userdb static" = {};

        # Localhost only. In 2.4 the bind address is this one global setting;
        # `inet_listener` no longer takes an `address`.
        listen = "127.0.0.1 ::1";

        "service imap-login" = {
          "inet_listener imap".port = 143;
          # Port 0 switches a default listener off.
          "inet_listener imaps".port = 0;
        };

        # The mandatory INBOX, parked behind a prefix so the archive can own
        # the root of the folder tree: Dovecot refuses two namespaces sharing
        # a prefix.
        "namespace inbox" = {
          inbox = true;
          prefix = "Personal/";
          separator = "/";
          list = false;
          hidden = true;
        };

        "namespace archive" =
          {
            type = "public";
            prefix = "";
            separator = "/";
            mail_driver = "maildir";
            mailbox_list_layout = "fs";
            mail_path = storeDir;
            list = true;
            # On because Roundcube's folder pane lists subscribed folders and
            # would otherwise show an empty archive; mail-archive-trees
            # subscribes the lot. The grant still decides visibility — LSUB is
            # ACL-filtered just as LIST is.
            subscriptions = true;
          }
          // lib.foldl' lib.mergeAttrs {} (lib.mapAttrsToList accountSettings cfg.accounts);
      };
    };

    systemd.services.dovecot = {
      unitConfig.OnFailure = "notify-failure@%n.service";

      # agenix swaps a symlink rather than rewriting the file, so restart on a
      # changed secret rather than work out whether Dovecot notices.
      #
      # Its own bytes, not its path: the path is inside `inputs.self`, whose
      # store hash covers the whole repo — a restart on every deploy.
      restartTriggers = [
        (builtins.hashFile "sha256" config.age.secrets.mailArchiveUsers.file)
      ];
    };

    systemd.services.mail-archive-trees = {
      description = "Materialise the archive tree of every declared source account";
      after = ["dovecot.service"];
      requires = ["dovecot.service"];
      wantedBy = ["multi-user.target"];
      unitConfig.OnFailure = "notify-failure@%n.service";
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = treesPass;
    };

    # The same pass at the end of every night's chain (ordering lives in
    # nightly.nix). Folders born from a mirror pass carry the
    # *source's* subscription state, which never includes INBOX — clients treat
    # it as implicitly subscribed — so without this catch-up a fresh account's
    # INBOX sits grayed out in Roundcube until the next deploy.
    #
    # A separate unit rather than a nightly re-run of the one above: mirror
    # passes are After= mail-archive-trees, so reusing it here would close an
    # ordering cycle.
    systemd.services.mail-archive-trees-refresh = {
      description = "Catch-up tree pass behind the night's mirrors";
      after = ["dovecot.service"];
      requires = ["dovecot.service"];
      unitConfig.OnFailure = "notify-failure@%n.service";
      serviceConfig.Type = "oneshot";
      script = treesPass;
    };

    # The enrolment list lives in the private input: this repo is public, and
    # the addresses, hosts and grants identify people. It is dumb data, so the
    # option types above still check every entry and a typo'd grant fails eval
    # loudly here. Enrolling an account is an entry there plus a line in the
    # mailSourcePasswords secret.
    homelab.mailArchive.accounts = import (inputs.nixhome-private + "/mail-accounts.nix");
  };
}
