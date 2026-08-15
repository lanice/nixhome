# Outbound mail: this host sends as its own mxroute mailbox, so the From
# address names the machine that had the problem. Importing this module is the
# whole cost — sender (contacts.<host>Sender) and password secret
# (mail<Host>Password.age) are derived from the hostname.
#
# Also provides the failure notifier every unit can hang off:
#   systemd.services.foo.unitConfig.OnFailure = "notify-failure@%n.service";
# %n hands the failing unit's full name to the instance, which the script
# then reads back as $1.
{
  inputs,
  pkgs,
  config,
  lib,
  ...
}: let
  contacts = import (inputs.nixhome-private + "/contacts.nix");

  hostName = config.networking.hostName;
  sender = contacts."${hostName}Sender";
  secretName = "mail${lib.toSentenceCase hostName}Password";

  # Local recipient; /etc/aliases below is what turns it into a real address.
  recipient = "root";

  notifyFailure = pkgs.writeShellScript "notify-failure" ''
    unit="$1"

    {
      printf 'To: %s\n' ${recipient}
      printf 'Subject: [${hostName}] %s failed\n' "$unit"
      printf 'MIME-Version: 1.0\n'
      printf 'Content-Type: text/plain; charset=UTF-8\n'
      printf '\n'

      # status exits non-zero for a failed unit, which is the only case this
      # script is ever called in.
      ${pkgs.systemd}/bin/systemctl status --full --lines=0 "$unit" || true

      printf '\n--- last 50 journal lines ---\n\n'
      ${pkgs.systemd}/bin/journalctl --unit="$unit" --lines=50 --no-pager
    } | ${pkgs.msmtp}/bin/msmtp --read-recipients
  '';
in {
  age.secrets.${secretName}.file = "${inputs.self}/secrets/${secretName}.age";

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
    accounts.default = {
      host = "witcher.mxrouting.net";
      user = sender;
      from = sender;
      passwordeval = "${pkgs.coreutils}/bin/cat ${config.age.secrets.${secretName}.path}";
    };
  };

  environment.etc.aliases.text = ''
    root: ${contacts.admin}
  '';

  systemd.services."notify-failure@" = {
    description = "Email notification for failed unit %i";
    after = ["network-online.target"];
    wants = ["network-online.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${notifyFailure} %i";
    };
  };
}
