{ pkgs, ... }:
{
  imports = [
    ./nix.nix
    ./sudo.nix
    ./boot.nix
    ./locale.nix
    ./openssh.nix
    ./timezone.nix
    ./system-packages.nix
  ];
}
