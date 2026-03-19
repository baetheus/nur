{ pkgs, ... }: {
  imports = [
    ./nix.nix
    ./timezone.nix
    ./locale.nix
    ./sudo.nix
    ./system-packages.nix
  ];
}
