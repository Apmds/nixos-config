{ pkgs, spicetify, ... }:

let
  spicePkgs = spicetify.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [
    spicetify.homeManagerModules.default
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
