{ pkgs, ... }: {
  imports = [
    ./nix.nix
    ./timezone.nix
    ./locale.nix
    ./boot.nix
    ./sudo.nix
    ./system-packages.nix
  ];
}
