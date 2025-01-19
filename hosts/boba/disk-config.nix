let
  nvme_onboard = "/dev/disk/by-id/nvme-KINGSTON_OM8PGP4256Q-A0_50026B7382FD4FE9";

  nvme_7thbay_0 = "/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_with_Heatsink_4TB_S7DSNJ0XA02005N";

  hdd24tb_0 = "/dev/disk/by-id/ata-ST24000NM000C-3WD103_ZXA05JEQ";
  hdd24tb_1 = "/dev/disk/by-id/ata-ST24000NM000H-3KS103_ZYD03ABA";
  hdd24tb_2 = "/dev/disk/by-id/ata-ST24000NM000H-3KS103_ZYD032PW";

  hdds_content = {
    type = "gpt";
    partitions = {
      zfs = {
        size = "100%";
        content = {
          type = "zfs";
          pool = "data";
        };
      };
    };
  };
in {
  disko = {
    devices = {
      disk = {
        nvme_onboard = {
          device = nvme_onboard;
          type = "disk";
          content = {
            type = "gpt";
            partitions = {
              boot = {
                name = "boot";
                size = "1M";
                type = "EF02";
              };
              esp = {
                name = "ESP";
                size = "1G";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                };
              };
              # root = {
              #   name = "root";
              #   size = "100%";
              #   content = {
              #     type = "lvm_pv";
              #     vg = "pool";
              #   };
              # };
              nix = {
                size = "100%";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/nix";
                };
              };
            };
          };
        };
        nvme_7thbay_0 = {
          type = "disk";
          device = nvme_7thbay_0;
          content = {
            type = "gpt";
            partitions = {
              zfs = {
                size = "100%";
                content = {
                  type = "zfs";
                  pool = "system";
                };
              };
            };
          };
        };
        hdd24tb_0 = {
          type = "disk";
          device = hdd24tb_0;
          content = hdds_content;
        };
        hdd24tb_1 = {
          type = "disk";
          device = hdd24tb_1;
          content = hdds_content;
        };
        hdd24tb_2 = {
          type = "disk";
          device = hdd24tb_2;
          content = hdds_content;
        };
      };
      # lvm_vg = {
      #   pool = {
      #     type = "lvm_vg";
      #     lvs = {
      #       root = {
      #         size = "100%FREE";
      #         content = {
      #           type = "filesystem";
      #           format = "ext4";
      #           mountpoint = "/nix";
      #           mountOptions = [
      #             "defaults"
      #           ];
      #         };
      #       };
      #     };
      #   };
      # };
      zpool = {
        system = {
          type = "zpool";

          rootFsOptions = {
            atime = "off";
            xattr = "sa";
            compression = "zstd";
          };

          options.ashift = "12";

          datasets = {
            "root" = {
              type = "zfs_fs";
              mountpoint = "/";
            };
            "var" = {
              type = "zfs_fs";
              mountpoint = "/var";
            };
            "home" = {
              type = "zfs_fs";
              mountpoint = "/home";
            };
            "downloads" = {
              type = "zfs_fs";
              mountpoint = "/downloads";
            };
          };
        };

        data = {
          type = "zpool";
          mountpoint = "/data";

          mode = {
            topology = {
              type = "topology";
              vdev = [
                {
                  members = ["hdd24tb_0" "hdd24tb_1" "hdd24tb_2"];
                  mode = "raidz1";
                }
              ];
            };
          };

          rootFsOptions = {
            atime = "off";
            xattr = "sa";
            compression = "zstd";
          };

          options.ashift = "12";

          datasets = {
            "media" = {
              type = "zfs_fs";
              mountpoint = "/data/media";
            };
            "backup" = {
              type = "zfs_fs";
              mountpoint = "/data/backup";
            };
          };
        };
      };
    };
  };
}
