{ config, pkgs, lib, ... }: let
  users = import ../../mixin/user.nix;
in {
  nixpkgs.hostPlatform = "x86_64-linux";

  imports = [
    ./disko.nix
    # Import common-nixos modules individually, skipping boot.nix (uses systemd-boot)
    ../../mixin/nix.nix
    ../../mixin/timezone.nix
    ../../mixin/locale.nix
    ../../mixin/sudo.nix
    ../../mixin/system-packages.nix
    # ZFS and services
    ../../mixin/zfs.nix
    ../../mixin/sops.nix
    ../../mixin/openssh.nix
    ../../mixin/tailscale.nix
  ] ++ users.default;

  # General
  system.stateVersion = "25.11";

  # Networking
  networking.hostName = "clementine";
  networking.hostId = "c1e4e771"; # Required for ZFS (8-char hex)
  networking.useDHCP = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  # GRUB bootloader for nixos-anywhere with ZFS support
  boot.loader.grub = {
    enable = true;
    zfsSupport = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    mirroredBoots = [
      { devices = [ "nodev" ]; path = "/boot"; }
      { devices = [ "nodev" ]; path = "/boot2"; }
    ];
  };

  # ZFS support
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.devNodes = "/dev/";

  # Add brandon keys to root
  users.users.root.openssh.authorizedKeys.keys = users.user.brandon.keys;
  # Override openssh to allow root login for nixos-anywhere
  services.openssh.settings.PermitRootLogin = lib.mkForce "prohibit-password";

  # Systemd service to sync /boot to /boot2 after rebuilds
  systemd.services.boot-mirror = {
    description = "Mirror /boot to /boot2 for redundant EFI boot";
    wantedBy = [ "multi-user.target" ];
    after = [ "local-fs.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.rsync}/bin/rsync -a --delete /boot/ /boot2/";
    };
  };

  # Run boot-mirror after nixos-rebuild
  system.activationScripts.boot-mirror = ''
    ${pkgs.systemd}/bin/systemctl start boot-mirror.service || true
  '';
}
