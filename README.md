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
2. Create a system configuration in [system/default.nix](./system/default.nix).
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
├── system/            # System configurations
│   ├── default.nix    # Exports nixosConfigurations and darwinConfigurations
│   ├── host/          # Per-host configurations (toph, abigail, diane, etc.)
│   ├── mixin/         # Reusable configuration modules
│   │   ├── minimal.nix        # Base setup (timezone, essential tools)
│   │   ├── common.nix         # NixOS-specific common settings
│   │   ├── darwin-minimal.nix # macOS-specific settings
│   │   ├── openssh.nix        # SSH hardening
│   │   ├── tailscale.nix      # VPN/mesh networking
│   │   ├── zfs.nix            # ZFS with auto-scrub and snapshots
│   │   └── ...
│   ├── module/        # Custom NixOS modules (fossil, photoprism, yubikey-agent)
│   ├── program/       # Home-manager program configs (git, zsh, vim, helix, etc.)
│   ├── profile/       # Profiles combining multiple programs (desktop.nix)
│   └── user/          # User configurations with metadata and SSH keys
├── template/          # Development templates
│   ├── simple/        # Basic flake template
│   └── rust/          # Rust development environment
├── package/           # Custom packages (placeholder)
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
- **Modular Mixins**: Reusable configs for services (openssh, tailscale, zfs, syncthing)
- **Program Configs**: Pre-configured git, zsh, vim, helix, jujutsu, direnv, zellij, alacritty

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
