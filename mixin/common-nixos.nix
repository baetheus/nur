{ pkgs, ... }:
{
  imports = [
    ./nix.nix
    ./sudo.nix
    ./locale.nix
    ./openssh.nix
    ./timezone.nix
    ./system-packages.nix
  ];
}
