{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    jujutsu
    ripgrep
    syncthing
  ];
}
