let
  # YubiKey identities
  keychain-a = "age1yubikey1q0w4elvpyp83lnat0hce5247rvuvmjnx2d670t0qp07447rxqyulx7tpv2r";
  folder-b = "age1yubikey1qwqyr54w5yseu8lwusqr9tvxm8e30tv7mn3xf4swjaq6r383985k5t7fp3y";
  laptop-c = "age1yubikey1qf95j5rtmv2tunv0a4f2qecnej37zsegy840g38aq5hvzcehv2d6jqpyvzw";

  admins = [
    keychain-a
    folder-b
    laptop-c
  ];

  # Host SSH public keys (from generated keypairs)
  hedy = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOQrDkQWu1OpswzEdJKcgMEevk+RAEYqNn46Qij/oNxB root@hedy";
  toph = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICsUOxhHkzo1XGriEX7Avnjez2D4GgTEDixtu2U9cp18 root@toph";
  grace = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK6B862RFK8HYt3qH4S0TANlXuc61gN5kAg9V7IbHZPp root@grace";
  amelia = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP590LO8yb/tAxeS6rnfZZ+5R4B6HBxJMeZTd89aXZrQ root@amelia";

  hosts = [
    hedy
    toph
    grace
    amelia
  ];

  all = admins ++ hosts;
in
{
  # Shared secrets (all NixOS hosts)
  "secrets/msmtp-passwordeval.age".publicKeys = all;
  "secrets/headscale-preauth-brandon.age".publicKeys = all;
  "secrets/brandon-password.age".publicKeys = all;

  # Host-specific secrets
  "secrets/wifi-tuna.age".publicKeys = admins ++ [
    toph
    grace
    amelia
  ];
  "secrets/vaultwarden.age".publicKeys = admins ++ [ toph ];
  "secrets/restic-htpasswd.age".publicKeys = admins ++ [ toph ];
  "secrets/nzbget-conf.age".publicKeys = admins ++ [ toph ];
  "secrets/restic-env-toph-persist.age".publicKeys = admins ++ [ toph ];
  "secrets/restic-env-hedy-persist.age".publicKeys = admins ++ [ hedy ];
  "secrets/restic-env-grace-persist.age".publicKeys = admins ++ [ grace ];
}
