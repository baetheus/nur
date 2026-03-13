{ pkgs, ... }: let
  users = import ../../mixin/user.nix;
in {
  nixpkgs.hostPlatform = "x86_64-darwin";

  imports = [ ../../mixin/common-darwin.nix ] ++ users.default;
}
