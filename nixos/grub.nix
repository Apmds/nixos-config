{config, pkgs, ...}:

{
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev"; # "nodev" is required for UEFI setups
  boot.loader.grub.useOSProber = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
