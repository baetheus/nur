{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:
let
  users = import ../../mixin/user.nix;
in
{
  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.facter.reportPath = ./facter.json;

  imports = [
    (modulesPath + "/profiles/qemu-guest.nix") # Needed for qemu host
    ./disko.nix
    ../../mixin/common-nixos.nix
    ../../mixin/boot-grub.nix
  ]
  ++ users.default;

  # General
  system.stateVersion = "25.11";

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
  # fileSystems."/persist".neededForBoot = true;
  # environment.persistence."/persist" = {
  #   enable = true;
  #   files = [
  #     "/etc/machine-id"
  #     "/etc/ssh/ssh_host_ed25519_key"
  #     "/etc/ssh/ssh_host_ed25519_key.pub"
  #     "/etc/ssh/ssh_host_rsa_key"
  #     "/etc/ssh/ssh_host_rsa_key.pub"
  #   ];
  #   directories = [
  #     "/var/lib/nixos"
  #     "/var/log"
  #   ];
  # };
}
