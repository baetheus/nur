{ pkgs, ... }: {
  imports = [
    ./nix.nix
    ./timezone.nix
    ./locale.nix
    ./boot.nix
    ./sudo.nix
    ./motd.nix
  ];

  # System packages available on all NixOS hosts
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    ripgrep
    darkhttpd
    syncthing
  ];
}
