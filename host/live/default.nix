{
  pkgs,
  modulesPath,
  ...
}:
let
  users = import ../../mixin/user.nix;
in
{
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "25.11";

  imports = [
    (modulesPath + "/installer/netboot/netboot-minimal.nix")
    ../../mixin/nix.nix
    ../../mixin/locale.nix
    ../../mixin/timezone.nix
    ../../mixin/system-packages.nix
  ];

  networking.hostName = "live";

  environment.systemPackages = with pkgs; [
    disko
  ];

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = false;
    };
    extraConfig = "PubkeyAuthOptions verify-required";
  };

  users.users.root.openssh.authorizedKeys.keys = users.user.brandon.keys;
}
