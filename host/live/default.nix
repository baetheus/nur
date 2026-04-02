{
  pkgs,
  ...
}:
let
  users = import ../../mixin/user.nix;
in
{
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "25.11";

  imports = [
    ./disko.nix
    ../../mixin/boot.nix
    ../../mixin/common-nixos.nix
  ]
  ++ users.default;

  networking.hostName = "live";

  environment.systemPackages = with pkgs; [
    disko
  ];
}
