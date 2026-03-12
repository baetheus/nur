{ pkgs, ... }: {
  imports = [
    ./nix.nix
    ./timezone.nix
    ./locale.nix
    ./boot.nix
    ./sudo.nix
    ./motd.nix
    ./system-packages.nix
  ];
}
