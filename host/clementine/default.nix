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
  hardware.facter.reportPath = ./facter.json;

  imports = [
    ./disko.nix
    ../../mixin/common-nixos.nix
    ../../mixin/zfs.nix
    ../../mixin/openssh.nix
    ../../mixin/sops.nix
    ../../mixin/tailscale.nix
  ]
  ++ users.default;

  # General
  system.stateVersion = "25.11";

  # Networking
  networking.hostName = "clementine";
  networking.hostId = "c1e4e771"; # Required for ZFS (8-char hex)
  networking.useDHCP = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

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
