{ pkgs, ... }: let
  user = import ../../user;
  profile = import ../../profile;
  userMixin = import ../../mixin/user.nix;
in {
  system = "x86_64-darwin";

  imports = [
    ../../mixin/common-darwin.nix
    (userMixin.mkZshUser {
      me = user.brandon;
      profile = profile.desktop;
      inherit pkgs;
    })
  ];
}
