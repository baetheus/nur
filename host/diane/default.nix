{ pkgs, ... }: let
  userMixin = import ../../mixin/user.nix;
  users = userMixin.users.default { inherit pkgs; };
in {
  nixpkgs.hostPlatform = "x86_64-darwin";

  imports = [
    ../../mixin/common-darwin.nix
    users
  ];
}
