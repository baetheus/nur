# Brandon's Nix User Repository

A flakes-only monorepo for managing system configurations, home environments, and development templates across macOS and NixOS machines.

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
2. Create a host configuration in [host/](./host/).
3. Push your changes.
4. Install or rebuild:

```sh
# If already on NixOS
nixos-rebuild switch --flake github:YOUR_REPO_PATH#YOUR_HOST_NAME

# Fresh install
nixos-install --flake github:YOUR_REPO_PATH#YOUR_HOST_NAME --root /YOUR_ROOT_MOUNT
```

## Structure

```
.
├── flake.nix          # Main flake with inputs and outputs
├── host/              # Per-host configurations (toph, abigail, diane, etc.)
├── mixin/             # Reusable configuration modules (services, programs)
├── module/            # Custom NixOS modules (fossil, photoprism, yubikey-agent)
├── profile/           # Profiles combining multiple mixins (desktop.nix)
├── user/              # User configurations with metadata and SSH keys
├── template/          # Development templates (simple, rust)
├── secret/            # Age-encrypted secrets (agenix)
└── files/             # Static files (scripts, printer drivers, themes)
```

## Templates

Create a new project from a template:

```sh
nix flake new -t github:baetheus/nur#simple .
nix flake new -t github:baetheus/nur#rust .
```

## Key Features

- **Secrets Management**: Age-encrypted secrets via agenix with YubiKey identities
- **Home Manager**: Integrated as a module for consistent dotfiles across systems
- **Modular Mixins**: Reusable configs for services and programs (openssh, tailscale, zfs, git, zsh, vim, helix, etc.)

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
   Confirm `/dev/sda` and `/dev/sdb` are the target disks. Adjust `host/<name>/disko.nix` if different.

3. Run nixos-anywhere from your local machine:
   ```sh
   nixos-anywhere --flake .#<hostname> root@<server-ip>
   ```

4. After installation completes, copy the age key to the server:
   ```sh
   scp /path/to/age-<hostname>.key root@<server-ip>:/keys/age-<hostname>.key
   ```

5. Reboot into the installed NixOS:
   ```sh
   ssh root@<server-ip> reboot
   ```

### Post-Deployment

1. Join Tailscale network:
   ```sh
   tailscale up
   ```

2. Verify ZFS pool status:
   ```sh
   zpool status rpool
   ```

3. Verify boot redundancy:
   ```sh
   ls /boot /boot2
   ```

## SSH Keys

I create FIDO2 credentials on YubiKeys and install the associated public keys on services I use. The credentials have a PIN and require touch.

To generate SSH keypairs from resident FIDO2 credentials:

```sh
ssh-keygen -K
```

This generates a keypair for each credential on each attached YubiKey.

Alternatively, add YubiKey FIDO2 credentials to ssh-agent (requires `ssh-askpass`):

```sh
ssh-add -K
```

## Questions

If you have questions, open a discussion. I'm always happy to dig into nix topics.
