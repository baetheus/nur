{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    watch
    jujutsu
    ripgrep
  ];
}
