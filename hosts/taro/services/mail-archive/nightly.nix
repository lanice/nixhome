# The nightly chain, started by a 02:30 timer:
# mirrors (one per source account, sequentially) → tree refresh → restic backup
# → anchor.
#
# Ordering is dependency-based, not wall-clock offsets (spec § Schedule), and
# After= is ordering only — a failed pass neither delays nor cancels anything
# behind it, so one bad account costs its own OnFailure email and nothing else.
# Sequential because mxroute is a small operator; one connection at a time.
#
# The anchor is a oneshot service rather than a target so it ends the night
# inactive: a target stays active once reached, and a timer firing at an
# already-active unit is a no-op — the second night would silently do nothing.
#
# It also owns the healthchecks.io dead-man ping: success only when every chain
# unit reports Result=success (Wants= means it runs even on a failed night),
# /fail otherwise. A chain that never ran pings nothing and trips the check's
# deadline instead.
{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.homelab.mailArchive;

  # systemd-escape at eval time: After= between template instances needs each
  # instance's unit name, which is the escaped address (mirror.nix
  # explains why the '@' cannot survive). systemd keeps alphanumerics, ':', '_'
  # and a non-leading '.', and turns every other byte — including '-' and '+' —
  # into lowercase \xNN; checked against `systemd-escape`.
  escapeInstance = s:
    lib.concatStrings (lib.imap0 (
      i: c:
        if builtins.match "[a-zA-Z0-9:_]" c != null || (c == "." && i != 0)
        then c
        else "\\x${lib.toLower (lib.fixedWidthString 2 "0" (lib.toHexString (lib.strings.charToInt c)))}"
    ) (lib.stringToCharacters s));

  # attrNames sorts, so the chain's shape is stable across deploys.
  addresses = lib.attrNames cfg.accounts;

  mirrorUnit = address: "mail-archive-mirror@${escapeInstance address}.service";

  # Everything the anchor waits for and health-checks, in chain order.
  chainUnits = map mirrorUnit addresses ++ ["mail-archive-trees-refresh.service"];
  backupUnit = "restic-backups-mail-archive.service";

  # The After= edges between consecutive passes, as drop-ins on the template
  # instances. The first account needs none; its ordering is the template's own.
  # imap0 gets the tail, so index i's predecessor is element i of the full list.
  ordering = lib.listToAttrs (lib.imap0 (i: address: {
      name = "mail-archive-mirror@${escapeInstance address}";
      value = {
        overrideStrategy = "asDropin";
        after = [(mirrorUnit (lib.elemAt addresses i))];
      };
    })
    (lib.drop 1 addresses));
in {
  age.secrets.mailArchiveHealthcheckUuid.file = "${inputs.self}/secrets/mailArchiveHealthcheckUuid.age";

  systemd.services =
    ordering
    // {
      # Subscribes and re-grants whatever the night's mirrors created
      # (mail-archive.nix).
      mail-archive-trees-refresh.after = map mirrorUnit addresses;

      # Snapshots what the night wrote (backup.nix).
      restic-backups-mail-archive.after = chainUnits;

      mail-archive-nightly = {
        description = "Nightly mail-archive chain";
        # Wants, never Requires: the anchor must run — and the chain must
        # count as attempted — even on a night where a pass failed.
        wants = chainUnits ++ [backupUnit];
        after = chainUnits ++ [backupUnit];
        unitConfig.OnFailure = "notify-failure@%n.service";
        serviceConfig.Type = "oneshot";
        # escapeShellArgs: instance names contain literal backslashes (\x40).
        script = ''
          failed=0
          for unit in ${lib.escapeShellArgs (chainUnits ++ [backupUnit])}; do
            result=$(${pkgs.systemd}/bin/systemctl show -p Result --value "$unit")
            if [ "$result" != success ]; then
              echo "chain unit $unit finished with Result=$result" >&2
              failed=1
            fi
          done

          uuid=$(cat ${config.age.secrets.mailArchiveHealthcheckUuid.path})
          if [ "$failed" = 0 ]; then
            ${pkgs.curl}/bin/curl -fsS -m 10 --retry 5 "https://hc-ping.com/$uuid"
            echo "chain complete: ${toString (lib.length addresses)} mirror passes, trees refresh, backup"
          else
            ${pkgs.curl}/bin/curl -fsS -m 10 --retry 5 "https://hc-ping.com/$uuid/fail"
            exit 1
          fi
        '';
      };
    };

  systemd.timers.mail-archive-nightly = {
    wantedBy = ["timers.target"];
    timerConfig = {
      # 02:30 keeps the restic leg clear of boba's ~00:00–00:15 I/O storm
      # and leaves room before taro's 04:31 Forgejo dump.
      OnCalendar = "*-*-* 02:30:00";
      # A missed night is made up at boot, outside the chosen window — safe,
      # since mirror passes only add.
      Persistent = true;
    };
  };
}
