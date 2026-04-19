{ config, pkgs, ... }:

{
  # Nvidia config
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;

    # 'open' should be true for newer cards (Turing+), false for older.
    open = true; 
    nvidiaSettings = true;
    # Ensure the stable/production driver is used
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # Setup PRIME Offload
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true; # Adds the 'nvidia-offload' command
      };
      # Replace these with the IDs from the lspci command above
      intelBusId = "PCI:0:2:0"; 
      nvidiaBusId = "PCI:1:0:0";
    };

    nvidiaPersistenced = true;
  };

  hardware.nvidia-container-toolkit.enable = true;
  virtualisation.docker.daemon.settings.features.cdi = true;
  virtualisation.docker.rootless.daemon.settings.features.cdi = true;
}
