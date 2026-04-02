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
    ../../mixin/boot.nix
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
    22 # SSH
    53 # CUP
    443 # HTTPS
    631
    6789 # NZBGet
    7878 # Radarr (Movies)
    8686 # Lidarr (Music)
    8989 # Sonarr (Series)
    32400 # Plex
  ];

  # Immutability
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
      # "/var/log" Naaaaah
      config.services.plex.dataDir
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

  services.nzbget = {
    enable = true;
    user = "media";
    group = "media";
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

}
