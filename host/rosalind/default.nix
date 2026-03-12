{ pkgs, ... }: let
  userMixin = import ../../mixin/user.nix;
  users = userMixin.users.default { inherit pkgs; };
in {
  nixpkgs.hostPlatform = "aarch64-darwin";

  imports = [
    ../../mixin/common-darwin.nix
    users
  ];

  environment.systemPackages = with pkgs; [
    bitwarden-desktop
  ];
}
