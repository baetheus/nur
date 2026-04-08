{ pkgs, ... }:
{
  nixpkgs.hostPlatform = "aarch64-darwin";
  system.stateVersion = 6;
  system.primaryUser = "brandon";

  imports = [
    ../../mixin/base-darwin.nix
    ../../mixin/user/brandon-darwin.nix
  ];

}
