{ self, inputs, ... }:
{
  flake.nixosConfigurations.hedy = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.diskoConfigurations.hedy
      self.modules.nixos.boot-grub
      self.modules.nixos.base
      self.modules.nixos.brandon
      self.modules.nixos.hedy
    ];
  };

  flake.modules.nixos.hedy =
    {
      config,
      pkgs,
      modulesPath,
      ...
    }:
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

          "vault.null.pub" = {
            forceSSL = true;
            enableACME = true;
            locations = {
              "/".proxyPass = "http://toph.at.null:8222";
              "= /notifications/anonymous-hub" = {
                proxyPass = "http://toph.at.null:8222";
                proxyWebsockets = true;
              };
              "= /notifications/hub" = {
                proxyPass = "http://toph.at.null:8222";
                proxyWebsockets = true;
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
          # Headscale
          {
            directory = "/var/lib/headscale";
            user = config.services.headscale.user; # Hardcoded in nixpkgs
            group = config.services.headscale.group; # Hardcoded in nixpkgs
          }
          # Acme
          {
            directory = "/var/lib/acme";
            user = "acme";
            group = "acme";
          }
          # Tailscale - uses root!
          "/var/lib/tailscale"
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
        extraUpFlags = [ "--login-server=${config.services.headscale.settings.server_url}" ];
        authKeyFile = config.age.secrets.headscale-preauth-brandon.path;
      };

      # Restic Backups
      age.secrets.restic-env-hedy-persist.file = ../../secrets/restic-env-hedy-persist.age;
      services.restic.backups.persist = {
        initialize = true;
        environmentFile = config.age.secrets.restic-env-hedy-persist.path;
        paths = [ "/persist" ];
      };

    };

}
