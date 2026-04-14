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
      networking.firewall.allowedTCPPorts = [
        22
        80
        443
        config.services.headscale.port
      ];

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
          "net.null.pub" = {
            forceSSL = true;
            enableACME = true;
            locations = {
              "/metrics" = {
                proxyPass = "http://${config.services.headscale.address}:${toString config.services.headscale.port}";
                extraConfig = ''
                  allow 100.64.0.0/16;
                  deny all;
                '';
                priority = 2;
              };

              "/" = {
                proxyPass = "http://${config.services.headscale.address}:${toString config.services.headscale.port}";
                proxyWebsockets = true;
                extraConfig = ''
                  keepalive_requests          100000;
                  keepalive_timeout           160s;
                  proxy_buffering             off;
                  proxy_connect_timeout       75;
                  proxy_ignore_client_abort   on;
                  proxy_read_timeout          900s;
                  proxy_send_timeout          600;
                  send_timeout                600;
                '';
                priority = 99;
              };
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
          {
            # Hardcoded in nixpkgs
            directory = "/var/lib/headscale";
            user = config.services.headscale.user;
            group = config.services.headscale.group;
          }
          {
            directory = "/var/lib/acme";
            user = "acme";
            group = "acme";
          }
          # "/var/log"
        ];
      };

      # Headscale
      services.headscale = {
        enable = true;
        address = "0.0.0.0";
        settings = {
          server_url = "https://net.null.pub";
          dns.base_domain = "at.null";
          dns.nameservers.global = [
            "1.1.1.1"
            "1.0.0.1"
            "2606:4700:4700::1111"
            "2606:4700:4700::1001"
          ];
        };
      };

      # Tailscale
      age.secrets.headscale-preauth-brandon.file = ../../secrets/headscale-preauth-brandon.age;
      services.tailscale = {
        enable = true;
        openFirewall = true;
        disableUpstreamLogging = true;
        useRoutingFeatures = "both";
        extraSetFlags = [ "--advertise-exit-node" ];
        authKeyFile = config.age.secrets.headscale-preauth-brandon.path;
        authKeyParameters.baseURL = config.services.headscale.settings.server_url;
        authKeyParameters.preauthorized = true;
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
