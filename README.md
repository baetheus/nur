# Brandon's Nix User Repository

A flakes-only monorepo for managing system configurations, home environments, and development templates across macOS and NixOS machines. Uses flake-parts for modular organization and impermanence for ephemeral root filesystems.

## Installation (darwin)

1. Clone this repository and `cd` into it.
2. Install [nix](https://nixos.org/download.html).
3. Enable nix flakes:

```sh
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

4. Build and switch to your host configuration:

```sh
nix build .#darwinConfigurations.HOST.system
./result/sw/bin/darwin-rebuild switch --flake .
```

## Installation (nixos)

1. Fork this repository.
2. Create a host configuration in [hosts/](./hosts/).
3. Push your changes.
4. Install or rebuild:

```sh
# If already on NixOS
nixos-rebuild switch --flake github:YOUR_REPO_PATH#YOUR_HOST_NAME

# Fresh install
nixos-install --flake github:YOUR_REPO_PATH#YOUR_HOST_NAME --root /YOUR_ROOT_MOUNT

# Fresh install with disko
nix run 'github:nix-community/disko/latest#disko-install' -- --flake github:REPO#HOST --disk main /dev/YOUR_DISK
```

## Structure

```
.
├── flake.nix          # Main flake with inputs and outputs
├── config.nix         # Flake-parts configuration
├── devshell.nix       # Development shell definition
├── secrets.nix        # Age encryption key mappings
├── hosts/             # Per-host configurations (toph, grace, hedy, amelia, rosalind)
├── features/          # Reusable NixOS/Darwin/Home modules organized by category
├── users/             # User configurations with metadata and SSH keys
├── templates/         # Development templates (simple, rust)
├── secrets/           # Age-encrypted secrets (ragenix)
├── identities/        # YubiKey age identity public keys
├── packages/          # Custom packages
└── files/             # Static files (scripts, firmware, themes, drivers)
```

## Templates

Create a new project from a template:

```sh
nix flake new -t github:baetheus/nur#simple .
nix flake new -t github:baetheus/nur#rust .
```

## Deployment (nixos-anywhere)

For deploying to dedicated servers (e.g., OVH) using nixos-anywhere with disko:

### Prerequisites

- nixos-anywhere installed (available in the dev shell: `nix develop`)
- SSH access to the target server in rescue mode
- YubiKey with FIDO2 credentials for SSH authentication

### Deployment Steps

1. Boot the server into rescue mode (Linux-based rescue system)

2. SSH into rescue mode and verify disk devices:
   ```sh
   ssh root@<server-ip>
   lsblk
   ```
   Confirm `/dev/sda` and `/dev/sdb` are the target disks. Adjust `hosts/<name>/disko.nix` if different.

3. Run nixos-anywhere from your local machine:
   ```sh
   nixos-anywhere --flake .#<hostname> root@<server-ip>
   ```

4. Get new hostkey and rekey secrets.
   ```sh
   # macOS - copy pubkey to clipboard
   ssh HOST cat /etc/ssh/ssh_host_ed25519_key.pub | pbcopy


   # linux (wayland) - copy host pubkey to primary clipboard
   ssh HOST cat /etc/ssh/ssh_host_ed25519_key.pub | wl-copy

   ```

   Rekey secrets `ragenix -i identities/IDENTITY_FILE -r`

   Commit the new keys and run `nixos-rebuild switch --flake github:REPO` to pick up the changes.

5. Reboot into the installed NixOS:
   ```sh
   ssh root@<server-ip> reboot
   ```

### Post-Deployment

1. Check system status:
   ```sh
    systemctl status
   ```

2. Check disk configuration (look for high disk usage - indicates a non-persisted service):
   ```sh
    df -h
   ```

## SSH Keys

I create FIDO2 credentials on YubiKeys and install the associated public keys on services I use. The credentials have a PIN and require touch.

To generate SSH keypairs from resident FIDO2 credentials:

```sh
ssh-keygen -K
```

This generates a keypair for each credential on each attached YubiKey.

Alternatively, add YubiKey FIDO2 credentials to ssh-agent (requires `ssh-askpass`) (DO NOT USE - ssh-agent blows):

```sh
ssh-add -K
```

## Questions

If you have questions, open a discussion. I'm always happy to dig into nix topics.
