{ pkgs, ... }:
{
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "25.11";

  imports = [
    ./disko.nix
    ../../mixin/base-nixos.nix
    ../../mixin/boot-systemd.nix
    ../../mixin/user/brandon-server.nix
  ];

  networking.hostName = "live";
  networking.hostId = "007f02aa";

  environment.systemPackages = with pkgs; [
    disko
  ];
}
