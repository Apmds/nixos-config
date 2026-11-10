# My NixOS config

This repository will contain all configurations from my NixOS system.

A single `flake.nix` at the repo root covers both NixOS and home-manager. It is symlinked into `nixos/` and `home-manager/` so each tool finds it automatically. Note that flake lock updates (`nix flake update`) should be run from `~/.config` (the repository root).

Some private assets (wallpapers, schedules, etc.) are fetched via the `assets` flake input. Swap that input for another if needed, but it will probably require you to change the paths where the `assets` input is used.

The NixOS system config lives in the [nixos](nixos/) directory and is symlinked at `/etc/nixos`.

This repo is currently sitting on the `~/.config` directory in my computer in case I really need to have other configs here that I couldn't just use nix for.

**Note**: If you don't like flakes for some reason and want to use this, a (completely not updated) branch named `legacy-flakeless` exists, though it is **NOT** recommended.

## Installing

Assuming you already have NixOS installed (or at least, the configs generated)

### Download

```bash
git clone git@github.com:Apmds/nixos-config.git ~/nixos-config-tmp
cp -r ~/nixos-config-tmp/. ~/.config/
rm -rf ~/nixos-config-tmp
```

This keeps all of your exisitng files in `~/.config`. If you don't want that (like when setting up a new machine), then just delete .config and clone directly to there.

### NixOS-specific setup

```bash
# Generate hardware config for your machine (do not use the one in this repo, it is device-specific)
nixos-generate-config --show-hardware-config > ~/.config/nixos/hardware-configuration.nix

# RECOMMENDED: backup generated/default configuration
cp -r /etc/nixos ~/.config/nixos-backup

# Symlink NixOS config into nixos directory
sudo rm -r /etc/nixos
sudo ln -s ~/.config/nixos /etc/nixos

sudo nixos-rebuild switch
```

Regarding secure boot, the system uses [Limine](https://wiki.nixos.org/wiki/Limine) as the bootloader, and as so it requires the secure boot keys to be enrolled **before** applying the config, as it assumes the keys are already enrolled. To enable secure boot on limine, follow the secure boot section from the [wiki](https://wiki.nixos.org/wiki/Limine). 

If you don't want secure boot enabled, you can either set `boot.loader.limine.secureBoot.enable` to `false` in [limine.nix](./nixos/limine.nix) or use GRUB, by changing the import file in [configuration.nix](./nixos/configuration.nix) from `limine.nix` to `grub.nix`.

### Home-manager setup

Because the `assets` flake input pulls from a private repository via SSH, an SSH key must be enrolled and added to GitHub before activating Home Manager.

```bash
# 1. Generate an SSH key
ssh-keygen -t ed25519 -C "your_email@example.com"

# 2. Add the key to ssh-agent
ssh-add ~/.ssh/id_ed25519

# 3. Copy public key and add it to your GitHub account (Settings -> SSH and GPG keys)
cat ~/.ssh/id_ed25519.pub

# 4. Verify access
ssh -T git@github.com
```

Bootstrap home-manager and activate the config with:

```bash
nix run home-manager/master -- switch
```

From then on, `home-manager switch` works directly.

## Nvidia

The [nvidia](nixos/nvidia.nix) module handles nvidia drivers. To "turn off" nvidia, comment the line in the "imports" section at the beggining of [configuration.nix](nixos/configuration.nix).
