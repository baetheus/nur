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
  ];

  networking.hostName = "live";

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
