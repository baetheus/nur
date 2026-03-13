{ pkgs, ... }: let
  users = ../../user.nix;
in {
  nixpkgs.hostPlatform = "aarch64-darwin";

  imports = [
    ../../mixin/common-darwin.nix
  ] ++ users.default;

  environment.systemPackages = with pkgs; [
    bitwarden-desktop
  ];
}
