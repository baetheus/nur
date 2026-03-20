{
  disko.devices = {
    nodev = {
      "/" = {
        fsType = "tmpfs";
        mountOptions = [
          "size=2G"
          "defaults"
          "mode=755"
        ];
      };
    };
    disk = {
      main = {
        device = "/dev/disk/by-id/nvme-ADATA_SX8200PNP_2K3629A97HPY";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
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
                pool = "rpool";
              };
            };
          };
        };
      };
      store1 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-WDC_WD40EFAX-68JH4N1_WD-WX22D616SAD8";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "store";
              };
            };
          };
        };
      };
      store2 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-ST4000DM000-1F2168_S3011SML";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "store";
              };
            };
          };
        };
      };
      store3 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-ST4000NM0035-1V4107_ZC13BWV4";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "store";
              };
            };
          };
        };
      };
      store4 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-ST4000NM0035-1V4107_ZC182W1Y";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "store";
              };
            };
          };
        };
      };
    };
    zpool = {
      rpool = {
        type = "zpool";
        # Workaround: cannot import 'zroot': I/O error in disko tests
        options.cachefile = "none";
        rootFsOptions = {
          mountpoint = "none";
          compression = "zstd";
        };
        datasets = {
          reserved = {
            type = "zfs_fs";
            options.mountpoint = "none";
            options.reservation = "12G";
          };
          nix = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/nix";
          };
        };
      };
      store = {
        type = "zpool";
        mode = "raidz1";
        rootFsOptions = {
          mountpoint = "none";
          compression = "zstd";
        };
        datasets = {
          reserved = {
            type = "zfs_fs";
            options.mountpoint = "none";
            options.reservation = "12G";
          };
          home = {
            type = "zfs_fs";
            mountpoint = "/home";
            options.mountpoint = "legacy";
            options."com.sun:auto-snapshot" = "true";
          };
          media = {
            type = "zfs_fs";
            mountpoint = "/store";
            options.mountpoint = "legacy";
            options."com.sun:auto-snapshot" = "false";
          };
          persist = {
            type = "zfs_fs";
            mountpoint = "/persist";
            options.mountpoint = "legacy";
            options."com.sun:auto-snapshot" = "true";
          };
        };
      };
    };
  };
}
