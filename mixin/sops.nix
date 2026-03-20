{ config, ... }: {
  sops.age.keyFile = "/persist/keys/age-${config.networking.hostName}.key";
}
