{ self, inputs, ... }:
{
  flake.nixosConfigurations.hedy = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.modules.nixos.boot-grub
      self.modules.nixos.base
      self.modules.nixos.brandon
      self.modules.nixos.hedy
      self.diskoConfigurations.hedy
    ];
  };

  flake.modules.nixos.hedy =
    { pkgs, modulesPath, ... }:
    {
      nixpkgs.hostPlatform = "x86_64-linux";
      hardware.facter.reportPath = ./facter.json;

      imports = [
        (modulesPath + "/profiles/qemu-guest.nix") # Needed for qemu host
      ];

      # General
      system.stateVersion = "25.11";
      age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICPhWmPVA6fwOTGbY1VGuYIQYnzCGqHGu2dadreUyT/w root@hedy";

      # Networking
      networking.hostName = "hedy";
      networking.hostId = "007f0201";
      networking.interfaces.eno1.useDHCP = true;

      # Firewall
      networking.firewall.enable = true;
      networking.firewall.allowedUDPPorts = [ ];
      networking.firewall.allowedTCPPorts = [ 22 ];

      # Immutability
      fileSystems."/".neededForBoot = true;
      fileSystems."/persist".neededForBoot = true;
      environment.persistence."/persist" = {
        enable = true;
        files = [
          "/etc/machine-id"
          "/etc/ssh/ssh_host_ed25519_key"
          "/etc/ssh/ssh_host_ed25519_key.pub"
          "/etc/ssh/ssh_host_rsa_key"
          "/etc/ssh/ssh_host_rsa_key.pub"
        ];
        directories = [
          "/var/lib/nixos"
          # "/var/log"
        ];
      };
    };

  flake.diskoConfigurations.hedy = {
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
          device = "/dev/sda";
          type = "disk";
          content = {
            type = "gpt";
            partitions = {
              boot = {
                name = "boot";
                size = "2M";
                type = "EF02";
              };
              esp = {
                name = "ESP";
                size = "300M";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
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
              options.reservation = "5G";
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
