{ pkgs, ... }: let
  users = import ../../mixin/user.nix;
in {
  nixpkgs.hostPlatform = "aarch64-darwin";
  system.stateVersion = 6;
  system.primaryUser = "brandon";

  imports = [
    ../../mixin/common-darwin.nix
  ] ++ users.default;

  environment.systemPackages = with pkgs; [
    bitwarden-desktop
  ];
}
