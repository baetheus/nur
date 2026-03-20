{ pkgs, ... }: let
  users = import ../../user.nix;
in {
  nixpkgs.hostPlatform = "aarch64-darwin";

  imports = [
    ../../mixin/common-darwin.nix
  ] ++ users.default;

  environment.systemPackages = with pkgs; [
    bitwarden-desktop
  ];
}
