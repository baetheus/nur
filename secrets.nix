let
  # YubiKey identities
  keychain-a = "age1yubikey1q0w4elvpyp83lnat0hce5247rvuvmjnx2d670t0qp07447rxqyulx7tpv2r";
  folder-b = "age1yubikey1qwqyr54w5yseu8lwusqr9tvxm8e30tv7mn3xf4swjaq6r383985k5t7fp3y";
  laptop-c = "age1yubikey1qf95j5rtmv2tunv0a4f2qecnej37zsegy840g38aq5hvzcehv2d6jqpyvzw";

  admins = [ keychain-a folder-b laptop-c ];

  # Host SSH public keys (from generated keypairs)
  live = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPq0/S6O8IaEeyWYMTos1qRFWKvoHUO5XqIAOrpVz+Bg live@nur";
  toph = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOQrDkQWu1OpswzEdJKcgMEevk+RAEYqNn46Qij/oNxB root@hedy";
  hedy = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICPhWmPVA6fwOTGbY1VGuYIQYnzCGqHGu2dadreUyT/w root@hedy";
  grace = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOyXQFxoPFXj+gSZveXoMim8k70nyf5qm8ABGg04dRAH grace@nur";
  abigail = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBQDE2Y/b4o7+892p3DHOPHOL8qLl+8Ct2LZoZpsjLe5 abigail@nur";
  bartleby = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBZTvXIbRQeXFqqukTZDA/t1m3+tTWB+XjW4UYJylJjx bartleby@nur";
  diane = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDwgPo6F2maHURrdx8WFJpQZrb15uGKtw9JRM1OQubHd diane@nur";
  rosalind = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBasbChiBgazhfEfM9UH8gOSIbWA3cQrlaBpXkvrw4RA rosalind@nur";

  nixosHosts = [ live toph hedy grace abigail bartleby ];
in
{
  # Shared secrets (all NixOS hosts)
  "modules/secrets/msmtp-passwordeval.age".publicKeys = admins ++ nixosHosts;
  "modules/secrets/wifi-tuna.age".publicKeys = admins ++ nixosHosts;
  "modules/secrets/k3s-token.age".publicKeys = admins ++ nixosHosts;
  "modules/secrets/innernet-config.age".publicKeys = admins ++ nixosHosts;
  "modules/secrets/miniflux-config.age".publicKeys = admins ++ nixosHosts;
  "modules/secrets/photoprism.age".publicKeys = admins ++ nixosHosts;

  # Host-specific secrets
  "modules/secrets/vaultwarden.age".publicKeys = admins ++ [ abigail ];
  "modules/secrets/basicauth.age".publicKeys = admins ++ [ bartleby ];
}
