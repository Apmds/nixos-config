# My NixOS config

This repository will contain all configurations from my NixOS system.

Currently it only has my home-manager config because I haven't (yet) ported my old config files to home-manager and haven't symlinked the NixOS configuration.nix in here.

This repo is currently sitting on the ~/.config directory in my computer in case I really need to have other configs here that I couldn't just use nix for.

## Installing

Assuming you already have NixOS installed (or at least, the configs generated)

### Download
```
cd ~/.config
git clone git@github.com:Apmds/nixos-config.git
```

### NixOS-specific setup:
```
cp /etc/nixos/hardware-configuration.nix ./nixos/hardware-configuration.nix  # Important to update 

# RECOMMENDED: backup generated/default configuration
cp -r /etc/nixos ~/.config/nixos-backup


sudo rm -r /etc/nixos
sudo ln -s ~/.config/nixos /etc/nixos
```

### Home-manager setup
Follow the [standalone installation](https://nix-community.github.io/home-manager/index.xhtml#sec-install-standalone) guide for home manager, then:
```
home-manager switch
```
