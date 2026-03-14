{ config, pkgs, ... }:

let
  # 1. Pull in flake-compat to translate the flake outputs for our non-flake setup
  flake-compat = import (fetchTarball "https://github.com/edolstra/flake-compat/archive/master.tar.gz");
  
  # 2. Use it to evaluate spicetify-nix
  spicetify-flake = (flake-compat {
    src = fetchTarball "https://github.com/Gerg-L/spicetify-nix/archive/master.tar.gz";
  }).defaultNix;

  # 3. Target your specific system architecture for the packages
  spicePkgs = spicetify-flake.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [
    spicetify-flake.homeManagerModules.default
  ];

  programs.spicetify = {
    enable = true;
    enabledExtensions = with spicePkgs.extensions; [
      adblockify
      hidePodcasts
      shuffle
    ];
    theme = spicePkgs.themes.catppuccin;
    colorScheme = "macchiato";
  };
}