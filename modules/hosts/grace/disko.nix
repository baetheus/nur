{ ... }: {
  flake.diskoConfigurations.grace = {
    disko.devices = {
      nodev."/" = {
        fsType = "tmpfs";
        mountOptions = [
          "size=2G"
          "defaults"
          "mode=755"
        ];
      };
      disk = {
        main = {
          device = "/dev/disk/by-id/nvme-SAMSUNG_MZVLB512HBJQ-000L7_S4ENNX0T800081";
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
            home = {
              type = "zfs_fs";
              mountpoint = "/home";
              options.mountpoint = "legacy";
              options."com.sun:auto-snapshot" = "true";
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
  };
}
