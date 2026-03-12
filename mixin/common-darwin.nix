{ pkgs, ... }: {
  imports = [
    ./nix.nix
    ./timezone.nix
    ./darwin.nix
  ];

  # Enable zsh
  programs.zsh.enable = true;

  # Primary user and state version
  system.primaryUser = "brandon";
  system.stateVersion = 5;

  # System packages available on all Darwin hosts
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    ripgrep
    darkhttpd
    syncthing
  ];
}
