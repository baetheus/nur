{ pkgs, ... }:
{
  imports = [
    ./nix.nix
    ./sudo.nix
    ./boot.nix
    ./locale.nix
    ./timezone.nix
    ./system-packages.nix
  ];
}
