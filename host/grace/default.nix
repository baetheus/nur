{ pkgs, ... }:
{
  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.facter.reportPath = ./facter.json;

  imports = [
    ./disko.nix
    ../../mixin/base-nixos.nix
    ../../mixin/boot-systemd.nix
    ../../mixin/user/brandon-desktop.nix
  ];

  # General
  system.stateVersion = "25.11";
  users.mutableUsers = true;

  # Networking
  networking.hostName = "grace";
  networking.hostId = "007f0215";
  networking.interfaces.enp0s31f6.useDHCP = true;

  # Firewall
  networking.firewall.enable = true;
  networking.firewall.allowedUDPPorts = [ ];
  networking.firewall.allowedTCPPorts = [ 22 ];

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
    ];
  };
}
