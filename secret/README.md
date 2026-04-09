# Agenix Secrets

This directory contains secrets encrypted with age via ragenix.

## Keys

- **YubiKey identities (3):** keychain-a, folder-b, laptop-c
- **Shared SSH key:** brandon@null.pub
- **Host SSH keys:** One per host in `keys/` directory

## Prerequisites

Enter the dev shell: `nix develop`

## Creating a New Secret

1. Add the secret definition to `secrets.nix`:
   ```nix
   "new-secret.age".publicKeys = admins ++ [ host1 host2 ];
   ```

2. Create and encrypt the secret:
   ```bash
   ragenix -e new-secret.age
   ```

3. Reference in NixOS config:
   ```nix
   age.secrets.new-secret.file = ../../secret/new-secret.age;
   ```

## Editing a Secret

```bash
ragenix -e <secret-name>.age
```

This decrypts, opens in $EDITOR, and re-encrypts on save.

## Deleting a Secret

1. Remove from `secrets.nix`
2. Remove the `.age` file
3. Remove references from NixOS configs

## Revoking Access to a Secret

1. Remove the key from the secret's `publicKeys` list in `secrets.nix`
2. Re-encrypt the secret:
   ```bash
   ragenix --rekey
   ```

## Adding a New Key to a Secret

1. Add the key variable to `secrets.nix` (if new)
2. Add the key to the secret's `publicKeys` list
3. Re-encrypt:
   ```bash
   ragenix --rekey
   ```

## Adding a New Host

1. Generate keypair:
   ```bash
   ssh-keygen -t ed25519 -N "" -C "hostname@nur" -f keys/hostname
   ```

2. Add public key to `secrets.nix`:
   ```nix
   hostname = "ssh-ed25519 <KEY> hostname@nur";
   ```

3. Add to relevant secrets' `publicKeys` lists

4. Re-encrypt secrets:
   ```bash
   ragenix --rekey
   ```

5. Deploy private key to host at `/persist/keys/age-hostname.key`

## Revoking a Host

1. Remove host from all `publicKeys` lists in `secrets.nix`
2. Re-encrypt all affected secrets:
   ```bash
   ragenix --rekey
   ```
3. Delete the keypair from `keys/`
