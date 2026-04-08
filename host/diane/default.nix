{ pkgs, ... }:
let
  users = import ../../mixin/user.nix;
in
{
  nixpkgs.hostPlatform = "x86_64-darwin";

  imports = [
    ../../mixin/base-darwin.nix
    ../../mixin/user/brandon-darwin.nix
  ];
}
