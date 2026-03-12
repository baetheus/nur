{ pkgs, ... }: let
  user = import ../../user;
  profile = import ../../profile;
  userMixin = import ../../mixin/user.nix;
in {
  nixpkgs.hostPlatform = "aarch64-darwin";
  system.stateVersion = 5;

  imports = [
    ../../mixin/minimal.nix
    ../../mixin/darwin-minimal.nix
    (userMixin.mkZshUser {
      me = user.brandon;
      profile = profile.desktop;
      inherit pkgs;
    })
  ];

  environment.systemPackages = with pkgs; [
    bitwarden-desktop
  ];
}
