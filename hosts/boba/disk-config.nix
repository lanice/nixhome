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

  # Copied from https://github.com/TheRealGramdalf/nixos/blob/main/disko/zfs-hybrid.nix
  default_rootFsOptions = {
    # These are inherited to all child datasets as the default value
    canmount = "off"; # ...Except for `canmount`
    mountpoint = "none"; # Don't mount the main pool anywhere
    atime = "off"; # atime generally sucks, only enable it when needed
    compression = "zstd"; # Slightly more CPU heavy, but better compressratio
    xattr = "sa"; # Store extra attributes with metadata, good for performance
    acltype = "posix"; # Allows extra attributes i.e. SELinux
    dnodesize = "auto"; # Requires a feature (ZFS 0.8.4+), but sizes metadata nodes more efficiently
    normalization = "formD"; # Validate and normalize file names, good for SMB
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
          options.ashift = "12";
          rootFsOptions = default_rootFsOptions;

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
          options.ashift = "12";
          rootFsOptions = default_rootFsOptions;

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

          datasets = {
            "media" = {
              type = "zfs_fs";
              mountpoint = "/data/media";
            };
            "vault" = {
              type = "zfs_fs";
              mountpoint = "/data/vault";
            };
            "storage" = {
              type = "zfs_fs";
              mountpoint = "/data/storage";
            };
          };
        };
      };
    };
  };
}
