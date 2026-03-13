{ config, ... }: {
  sops.age.keyFile = "/keys/age-${config.networking.hostName}.key";
}
