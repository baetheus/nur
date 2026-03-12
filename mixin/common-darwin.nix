{ pkgs, ... }: {
  imports = [
    ./nix.nix
    ./timezone.nix
    ./darwin.nix
    ./system-packages.nix
  ];
}
