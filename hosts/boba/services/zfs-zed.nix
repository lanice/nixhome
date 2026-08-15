# https://wiki.nixos.org/wiki/ZFS#Mail_notifications_(ZFS_Event_Daemon)
#
# Mail delivery itself (msmtp, aliases, secret) comes from ../../common/mail.nix.
{pkgs, ...}: {
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
