{
  # Samsung 870 EVO 500GB (SATA). The onboard eMMC (mmc-Biwin_0xa2ae2ebe) is
  # deliberately left untouched — it still holds ZimaOS, which is the only
  # rescue path on this headless board if a rebuild leaves it unbootable.
  disko.devices.disk.ssd = {
    device = "/dev/disk/by-id/ata-Samsung_SSD_870_EVO_500GB_S6PXNS0L613131R";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = ["umask=0077"];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
