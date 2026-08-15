# Outbound mail from taro, and the failure notifier every other unit hangs off.
#
# Same shape as boba's ZED mail path (hosts/boba/services/zfs-zed.nix): each
# host that sends mail authenticates as its own mxroute mailbox, so the From
# address names the machine that had the problem.
{
  inputs,
  pkgs,
  config,
  ...
}: let
  contacts = import (inputs.nixhome-private + "/contacts.nix");

  # Local recipient; /etc/aliases below is what turns it into a real address.
  recipient = "root";

  notifyFailure = pkgs.writeShellScript "notify-failure" ''
    unit="$1"

    {
      printf 'To: %s\n' ${recipient}
      printf 'Subject: [taro] %s failed\n' "$unit"
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
  age.secrets.mailTaroPassword.file = "${inputs.self}/secrets/mailTaroPassword.age";

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
      user = contacts.taroSender;
      from = contacts.taroSender;
      passwordeval = "${pkgs.coreutils}/bin/cat ${config.age.secrets.mailTaroPassword.path}";
    };
  };

  environment.etc.aliases.text = ''
    root: ${contacts.admin}
  '';

  # Attaching this to a unit is one line:
  #   systemd.services.foo.unitConfig.OnFailure = "notify-failure@%n.service";
  # %n hands the failing unit's full name to the instance, which the script
  # then reads back as $1.
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
