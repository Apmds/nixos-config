{config, pkgs, ...}:

{
  boot.loader = {
    limine = {
      enable = true;
      extraEntries = ''
        /Windows
          protocol: efi
          path: boot():/EFI/Microsoft/Boot/bootmgfw.efi
      '';
      secureBoot.enable = true;
    };
    efi.canTouchEfiVariables = true;
  };

  environment.systemPackages = [ pkgs.sbctl ];
}
