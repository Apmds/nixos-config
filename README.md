# My NixOS config

This repository will contain all configurations from my NixOS system.

A single `flake.nix` at the repo root covers both NixOS and home-manager. It is symlinked into `nixos/` and `home-manager/` so each tool finds it automatically.

The NixOS system config lives in the [nixos](nixos/) directory and is symlinked at `/etc/nixos`.

This repo is currently sitting on the `~/.config` directory in my computer in case I really need to have other configs here that I couldn't just use nix for.

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

### Home-manager setup

```bash
nix run home-manager/master -- switch
```

This bootstraps home-manager and activates the config. From then on, `home-manager switch` works directly.

## Nvidia

The [nvidia](nixos/nvidia.nix) module handles nvidia drivers. To "turn off" nvidia, comment the line in the "imports" section at the beggining of [configuration.nix](nixos/configuration.nix).
