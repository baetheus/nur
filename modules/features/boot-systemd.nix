{ self, inputs, ... }:
{
  flake.modules.nixos.boot-systemd = {
    boot.loader.systemd-boot.enable = true;
    boot.loader.systemd-boot.configurationLimit = 3;
    boot.loader.efi.canTouchEfiVariables = true;
  };
}
