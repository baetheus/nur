{ self, inputs, ... }:
{
  flake.nixosConfigurations.toph = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.diskoConfigurations.toph
      self.modules.nixos.nzbgetService # Maybe move this to a "replacedModules"
      self.modules.nixos.boot-systemd
      self.modules.nixos.base
      self.modules.nixos.brandon
      self.modules.nixos.toph
    ];
  };

  flake.modules.nixos.toph = {
    config,
    pkgs,
    ...
  }:
  {
    # General
    system.stateVersion = "25.11";
    nixpkgs.hostPlatform = "x86_64-linux";
    nixpkgs.config.allowUnfree = true; # For samsung driver
    hardware.facter.reportPath = ./facter.json;

    # Networking
    networking.hostName = "toph";
    networking.hostId = "007f0200";
    networking.interfaces.eno1.useDHCP = true;

    # Wifi
    # age.secrets."tuna-wifi".file = ../../secrets/wifi-tuna.age;
    # networking.wireless.enable = true;
    # networking.interfaces.wlp0s20f3.useDHCP = true;
    # networking.supplicant.WLAN.configFile.path = config.age.secrets."tuna-wifi".path;

    # Firewall
    networking.firewall.enable = true;
    networking.firewall.allowedUDPPorts = [ 41641 ];
    networking.firewall.allowedTCPPorts = [
      22 # SSH
      53 # CUP
      443 # HTTPS
      631 # Print Sharing
      6789 # NZBGet
      7878 # Radarr (Movies)
      8686 # Lidarr (Music)
      8989 # Sonarr (Series)
    ];

    # Immutability
    fileSystems."/".neededForBoot = true;
    fileSystems."/home".neededForBoot = true;
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
        # Plex
        {
          directory = config.services.plex.dataDir;
          user = config.services.plex.user;
          group = config.services.plex.group;
        }
        # NZBGet
        {
          directory = config.services.nzbget.dataDir;
          user = config.services.nzbget.user;
          group = config.services.nzbget.group;
        }
        # Restic Server
        {
          directory = config.services.restic.server.dataDir;
          user = "restic"; # Hardcoded in nixpkgs
          group = "restic"; # Hardcoded in nixpkgs
        }
        # Tailscale - uses root!
        "/var/lib/tailscale"
      ];
    };

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

    # Tailscale
    age.secrets.headscale-preauth-brandon.file = ../../secrets/headscale-preauth-brandon.age;
    services.tailscale = {
      enable = true;
      openFirewall = true;
      disableUpstreamLogging = true;
      useRoutingFeatures = "both";
      extraUpFlags = [ "--login-server=https://net.null.pub" ];
      authKeyFile = config.age.secrets.headscale-preauth-brandon.path;
    };

    # Restic Server
    age.secrets.restic-htpasswd = {
      file = ../../secrets/restic-htpasswd.age;
      owner = "restic";
      group = "restic";
    };
    services.restic.server = {
      enable = true;
      privateRepos = true;
      htpasswd-file = config.age.secrets.restic-htpasswd.path;
    };

    # Restic Backups
    age.secrets.restic-env-toph-persist.file = ../../secrets/restic-env-toph-persist.age;
    services.restic.backups.persist = {
      initialize = true;
      environmentFile = config.age.secrets.restic-env-toph-persist.path;
      paths = [ "/persist" ];
    };

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

    services.plex = {
      enable = true;
      user = "media";
      group = "media";
    };

    age.secrets.nzbget-conf = {
      file = ../../secrets/nzbget-conf.age;
      owner = "media";
      group = "media";
    };
    services.nzbget = {
      enable = true;
      user = "media";
      group = "media";
      configFile = config.age.secrets.nzbget-conf.path;
    };

    services.sonarr = {
      enable = true;
      user = "media";
      group = "media";
    };

    services.radarr = {
      enable = true;
      user = "media";
      group = "media";
    };

    services.lidarr = {
      enable = true;
      user = "media";
      group = "media";
    };
  };
}
