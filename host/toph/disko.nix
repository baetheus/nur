{
  disko.devices = {
    disk = {
      nvme = {
        device = "/dev/disk/by-id/nvme-ADATA_SX8200PNP_2K3629A97HPY";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02"; # for grub MBR
            };
            ESP = {
              type = "EF00";
              size = "512M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "root";
              };
            };
          };
        };
      };
      storage1 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-WDC_WD40EFAX-68JH4N1_WD-WX22D616SAD8";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "storage";
              };
            };
          };
        };
      };
      storage2 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-ST4000DM000-1F2168_S3011SML";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "storage";
              };
            };
          };
        };
      };
      storage3 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-ST4000NM0035-1V4107_ZC13BWV4";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "storage";
              };
            };
          };
        };
      };
      storage4 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-ST4000NM0035-1V4107_ZC182W1Y";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "storage";
              };
            };
          };
        };
      };
    };
    zpool = {
      root = {
        type = "zpool";
        # Workaround: cannot import 'zroot': I/O error in disko tests
        options.cachefile = "none";
        options.mountpoint = "legacy";
        rootFsOptions = {
          compression = "zstd";
          "com.sun:auto-snapshot" = "false";
        };
        mountpoint = "/";
        postCreateHook = "zfs list -t snapshot -H -o name | grep -E '^root@blank$' || zfs snapshot root@blank";
      };
      storage = {
        type = "zpool";
        mode = "raidz1";
        # Workaround: cannot import 'zroot': I/O error in disko tests
        options.cachefile = "none";
        rootFsOptions = {
          compression = "zstd";
          "com.sun:auto-snapshot" = "false";
        };
        # postCreateHook = "zfs list -t snapshot -H -o name | grep -E '^zroot@blank$' || zfs snapshot zroot@blank";
        datasets = {
          home = {
            type = "zfs_fs";
            mountpoint = "/home";
            options.mountpoint = "legacy";
            options."com.sun:auto-snapshot" = "true";
          };
          media = {
            type = "zfs_fs";
            mountpoint = "/media";
            options.mountpoint = "legacy";
            options."com.sun:auto-snapshot" = "false";
          };
        };
      };
    };
  };
}
