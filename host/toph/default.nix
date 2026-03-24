{
  config,
  pkgs,
  lib,
  ...
}:
let
  users = import ../../mixin/user.nix;
in
{
  nixpkgs.hostPlatform = "x86_64-linux";
  nixpkgs.config.allowUnfree = true; # For samsung driver
  hardware.facter.reportPath = ./facter.json;

  imports = [
    ./disko.nix
    ../../mixin/common-nixos.nix
    ../../mixin/zfs.nix
    ../../mixin/sops.nix
    ../../mixin/tailscale.nix
  ]
  ++ users.default;

  # General
  system.stateVersion = "25.11";

  # Networking
  networking.hostName = "toph";
  networking.hostId = "007f0200";
  networking.interfaces.eno1.useDHCP = true;

  # Firewall
  networking.firewall.enable = true;
  networking.firewall.allowedUDPPorts = [ 41641 ];
  networking.firewall.allowedTCPPorts = [
    22
    53
    443
    631
    32400
  ];

  # Printing
  services.printing.enable = true;
  services.printing.browsing = true;
  services.printing.listenAddresses = [ "*:631" ];
  services.printing.allowFrom = [ "all" ];
  services.printing.defaultShared = true;
  services.printing.drivers = [ pkgs.samsung-unified-linux-driver ];

  # Service discovery
  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;
  services.avahi.openFirewall = true;
  services.avahi.publish.enable = true;
  services.avahi.publish.domain = true;
  services.avahi.publish.userServices = true;

  # Media
  users = {
    users.media = {
      group = "media";
      isSystemUser = true;
    };
    groups.media = {
      members = [ "media" ];
    };
  };

  # Nginx
  services.nginx = {
    enable = true;

    virtualHosts = {
      "toph.lan" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          root = "/var/www/toph.lan";
          extraConfig = "autoindex on;";
        };
      };

      "plex.null.pub" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://0.0.0.0:32400";
          proxyWebsockets = true;
        };
      };

      "nzbget.null.pub" = {
        forceSSL = true;
        enableACME = true;
        basicAuthFile = config.sops.secrets.basicauth.path;
        locations."/" = {
          proxyPass = "http://0.0.0.0:6789";
          proxyWebsockets = true;
        };
      };

      "series.null.pub" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://0.0.0.0:8989";
          proxyWebsockets = true;
        };
      };

      "movies.null.pub" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://0.0.0.0:7878";
          proxyWebsockets = true;
        };
      };

      "music.null.pub" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://0.0.0.0:8686";
          proxyWebsockets = true;
        };
      };
    };
  };

  # Syncthing
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    dataDir = "/home/brandon/sync";
    configDir = "/home/brandon/.config/syncthing";
    user = "brandon";
    group = "users";
    guiAddress = "0.0.0.0:8384";
    overrideFolders = true;
    overrideDevices = true;

    settings.devices = {
      "rosalind" = {
        id = "FIFUNFL-3QFVW3N-5P7XESL-Q7JZF4S-55B7TTY-2KG57S5-5JYAZVE-KHDOGAW";
        addresses = [ "tcp://rosalind:22000" ];
      };
      "abigail" = {
        id = "5HMRD3B-UWFLIFC-XDY2NPO-TVWGA2U-GB5H2CT-FUFWNDB-OTKAGEQ-JGLF5QF";
        addresses = [ "tcp://abigail:22000" ];
      };
      "bartleby" = {
        id = "OKG5G4Y-BJDA6GS-3G6XCCN-QZC6RIS-N7QDDS5-WL6MO2C-N74QD3S-YC5AIQ5";
        addresses = [ "tcp://bartleby:22000" ];
      };
      "diane" = {
        id = "D5TXPEW-4MFW7PA-4HANFUA-XU7ZTDJ-I7PUNHU-5EC4YSQ-AA46NZM-OX7VDAO";
        addresses = [ "tcp://diane:22000" ];
      };
    };

    settings.folders = {
      "share" = {
        id = "xa7yg-wn5qo";
        type = "receiveonly";
        path = "/home/brandon/share";
        devices = [
          "rosalind"
          "abigail"
          "bartleby"
          "diane"
        ];
      };

      "photos" = {
        id = "xa7yg-ph0to";
        type = "receiveonly";
        path = "/media/photos";
        devices = [
          "rosalind"
          "abigail"
          "bartleby"
          "diane"
        ];
      };

      "music" = {
        id = "xa7yg-mu5ic";
        type = "receiveonly";
        path = "/media/music";
        devices = [
          "rosalind"
          "abigail"
          "bartleby"
          "diane"
        ];
      };
    };
  };

  # Setup filesystem and paths we need to keep between boots
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
      "/var/log"
      "/var/lib/nixos"
    ];
  };
}
