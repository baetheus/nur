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
    { config, pkgs, modulesPath, ... }:
    {
      nixpkgs.hostPlatform = "x86_64-linux";
      hardware.facter.reportPath = ./facter.json;

      imports = [
        (modulesPath + "/profiles/qemu-guest.nix") # Needed for qemu host
      ];

      # General
      system.stateVersion = "25.11";

      # Networking
      networking.hostName = "hedy";
      networking.hostId = "007f0201";

      # Firewall
      networking.firewall.enable = true;
      networking.firewall.allowedTCPPorts = [ 22 ];

      # Pangolin
      # age.secrets.pangolin.file = ../secrets/pangolin.age;
      # services.pangolin = {
      #   enable = true;
      #   openFirewall = true;
      #   baseDomain = "null.pub";
      #   letsEncryptEmail = "admin@null.pub";
      #   environmentFile = config.age.secrets.pangolin.path;
      # };

      services.pocket-id = {
        enable = true;
        settings = {
          TRUST_PROXY = true;
          APP_URL = "https://auth.null.pub";
        };
      };

      # Netbird
      age.secrets.netbird-coturn = {
        file = ../../secrets/netbird-coturn.age;
        mode = "770";
        owner = config.services.netbird.server.coturn.user;
        group = "root";
      };
      services.netbird.server = {
        enable = true;
        domain = "netbird.null.pub";

        dashboard = {
          enable = true;
          domain = "netbird-dash.null.pub";
          enableNginx = true;
          settings.AUTH_AUTHORITY = config.services.pocket-id.settings.APP_URL;
        };

        management = {
          oidcConfigEndpoint = "https://id.example.com/.well-known/openid-configuration";
        };

        coturn = {
          enable = true;
          domain = "netbird-coturn.null.pub";
          passwordFile = config.age.secrets.netbird-coturn.path;
        };
      };

      # Nginx
      security.acme.acceptTerms = true;
      security.acme.defaults.email = "admin@null.pub";

      services.nginx = {
        enable = true;

        recommendedTlsSettings = true;
        recommendedOptimisation = true;
        recommendedGzipSettings = true;
        recommendedProxySettings = true;
        clientMaxBodySize = "500m";

        virtualHosts = {
          "auth.null.pub" = {
            enableACME = true;
            forceSSL = true;
            locations."/" = {
              proxyPass = "http://[::1]:1411";
              proxyWebsockets = true;
              recommendedProxySettings = true;
              extraConfig = ''
                client_max_body_size 50000M;
                proxy_read_timeout   600s;
                proxy_send_timeout   600s;
                send_timeout         600s;
              '';
            };
          };
        };
      };

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
          # config.services.pangolin.dataDir
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
