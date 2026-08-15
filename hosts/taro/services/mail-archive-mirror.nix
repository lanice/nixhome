# Mirror passes: copying a source account's mail into the archive.
#
# A mirror pass only ever adds (CONTEXT.md § Mail archive): no age filter, no
# deletion flag on either side, so re-running is safe by construction —
# imapsync compares message headers and skips what is already there.
#
# One template instance per source account, chained by the nightly timer
# (mail-archive-nightly.nix). By hand:
#
#   systemctl start "mail-archive-mirror@$(systemd-escape hi@example.com)"
#
# The escaping is required — systemd splits template names on '@' — and %I
# hands the address back to the script unescaped.
{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.homelab.mailArchive;

  syncUser = "archive-sync";

  # Perl regex against the source's folder names. Anchored on a separator so a
  # folder at any depth is caught — mxroute holds both 'Junk' and 'INBOX.spam',
  # hence also the (?i) — while 'Junk mail from 2019' is not.
  excludeFolders = "(?i)(^|[./])(Junk|Spam|Trash)$";

  # One top-level tree per account, keyed by full address. The '@' goes in
  # backslashed: imapsync hands the replacement to Perl's eval, where a bare
  # '@' starts an array interpolation and aborts the run.
  #
  # No prefix stripping: mxroute presents 'Sent', not 'INBOX.Sent', and
  # stripping 'INBOX/' would fold a real subfolder of INBOX onto its namesake.
  treeTransform = address: "s,^,${lib.replaceStrings ["@"] ["\\@"] address}/,";

  # An undeclared address fails here rather than reaching mxroute.
  accountLookup = let
    arms = lib.concatStrings (lib.mapAttrsToList
      (address: account: "  ${lib.escapeShellArg address}) host=${lib.escapeShellArg account.host} transform=${lib.escapeShellArg (treeTransform address)} ;;\n")
      cfg.accounts);
  in ''
    case "$account" in
    ${arms}  *)
        echo "not a declared source account: $account" >&2
        exit 1
        ;;
    esac
  '';

  mirror = pkgs.writeShellScript "mail-archive-mirror" ''
    set -euo pipefail

    account="$1"

    ${accountLookup}

    # Copied out of CREDENTIALS_DIRECTORY because imapsync gates each
    # --passfile on Perl's `-r`, which checks mode bits and ownership only —
    # an ACL-readable root:root 0440 credential still fails it.
    umask 077
    sourcefile="$RUNTIME_DIRECTORY/source-password"
    archivefile="$RUNTIME_DIRECTORY/archive-password"

    # One 'address:password' line per account, all in one secret. Split on the
    # first colon only: a password may contain one, an address never does.
    ${lib.getExe' pkgs.gawk "awk"} -v account="$account" -F: '
      $1 == account { print substr($0, length(account) + 2); found = 1; exit }
      END { if (!found) { print "no password on file for " account > "/dev/stderr"; exit 1 } }
    ' "$CREDENTIALS_DIRECTORY/source-password" > "$sourcefile"

    ${pkgs.coreutils}/bin/cp "$CREDENTIALS_DIRECTORY/archive-password" "$archivefile"

    # --addheader is what keeps Sent and Drafts from being silently skipped:
    # messages there often never got a Message-Id, and header comparison is
    # how imapsync decides what it has already copied.
    exec ${lib.getExe' pkgs.imapsync "imapsync"} \
      --host1 "$host" --user1 "$account" --passfile1 "$sourcefile" --ssl1 \
      --host2 127.0.0.1 --port2 143 --nossl2 --notls2 \
      --user2 ${syncUser} --passfile2 "$archivefile" \
      --exclude ${lib.escapeShellArg excludeFolders} \
      --regextrans2 "$transform" \
      --addheader \
      --nofoldersizes --nofoldersizesatend \
      --noreleasecheck \
      --nolog \
      --tmpdir "$RUNTIME_DIRECTORY"
  '';
in {
  # Both plaintext, because imapsync has to present them.
  #
  # mailArchiveSyncPassword holds the same password that mailArchiveUsers holds
  # a hash of. Nothing checks that the two agree; a half-done change surfaces
  # only as `Authentication failed` in a mirror pass.
  age.secrets = {
    mailSourcePasswords = {
      file = "${inputs.self}/secrets/mailSourcePasswords.age";
      mode = "400";
    };
    mailArchiveSyncPassword = {
      file = "${inputs.self}/secrets/mailArchiveSyncPassword.age";
      mode = "400";
    };
  };

  systemd.services."mail-archive-mirror@" = {
    description = "Mirror pass for source account %I";
    after = ["network-online.target" "dovecot.service" "mail-archive-trees.service"];
    wants = ["network-online.target"];
    requires = ["dovecot.service"];
    unitConfig.OnFailure = "notify-failure@%n.service";

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${mirror} %I";

      # A first pass copies an account's whole backlog and can run for hours.
      TimeoutStartSec = "infinity";

      DynamicUser = true;
      RuntimeDirectory = "mail-archive-mirror";
      RuntimeDirectoryMode = "0700";
      WorkingDirectory = "/run/mail-archive-mirror";

      LoadCredential = [
        "source-password:${config.age.secrets.mailSourcePasswords.path}"
        "archive-password:${config.age.secrets.mailArchiveSyncPassword.path}"
      ];

      CapabilityBoundingSet = "";
      LockPersonality = true;
      NoNewPrivileges = true;
      PrivateDevices = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      ProtectSystem = "strict";
      RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6"];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      SystemCallFilter = ["@system-service" "~@privileged"];
    };
  };
}
