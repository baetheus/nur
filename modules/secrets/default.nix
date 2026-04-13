{ self, inputs, ... }:
{
  flake.modules.nixos.rekey = { config, ... }: {
    age.rekey = {
      masterIdentities = [
        ./age-yubikey-folder-b.pub
        ./age-yubikey-keychain-a.pub
        ./age-yubikey-laptop-c.pub
      ];
      storageMode = "local";
      localStorageDir = ./. + "/secrets/rekeyed/${config.networking.hostName}";
    };
  };
}
