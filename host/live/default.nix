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

  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    ../../mixin/nix.nix
    ../../mixin/locale.nix
    ../../mixin/timezone.nix
    ../../mixin/system-packages.nix
  ]

  services.openssh = {
    enable = true;
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = true;
    PermitRootLogin = "yes";
  };

  users.users.root.openssh.authorizedKeys.keys = users.user.brandon.keys;
}
