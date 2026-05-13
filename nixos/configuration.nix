# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  nmUiSrc = pkgs.fetchFromGitHub {
    owner = "Blazzzeee";
    repo = "network_manager_ui";
    rev = "master";
    sha256 = "sha256-2w2GI/WF9MQseAQCxjB1HYEAcOmMNv1lQbfgLbkwHsw=";
  };

  flakeCompat = import (builtins.fetchTarball "https://github.com/edolstra/flake-compat/archive/master.tar.gz") {
    src = nmUiSrc;
  };

  network_manager_ui = pkgs.callPackage "${nmUiSrc}/nix" { };

  swtchr = pkgs.callPackage ./derivations/swtchr.nix { };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./nvidia.nix # Comentar e descomentar para ter drivers e docker da nvidia
    ];

  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w"
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = false; # Disable systemd-boot for now
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev"; # "nodev" is required for UEFI setups
  boot.loader.grub.useOSProber = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # For drawing tablet
  hardware.opentabletdriver.enable = true;
  boot.kernelModules = [ "uinput" ];

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Lisbon";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_PT.UTF-8";
    LC_IDENTIFICATION = "pt_PT.UTF-8";
    LC_MEASUREMENT = "pt_PT.UTF-8";
    LC_MONETARY = "pt_PT.UTF-8";
    LC_NAME = "pt_PT.UTF-8";
    LC_NUMERIC = "pt_PT.UTF-8";
    LC_PAPER = "pt_PT.UTF-8";
    LC_TELEPHONE = "pt_PT.UTF-8";
    LC_TIME = "pt_PT.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "pt";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "pt-latin1";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.apmds = {
    isNormalUser = true;
    description = "Apmds";
    extraGroups = [ "networkmanager" "wheel" "docker" "video" "render" "wireshark" ];
    packages = with pkgs; [];
  };

  programs.nix-ld.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    firefox
    networkmanagerapplet
    fastfetch
    polkit_gnome
    nemo
    pavucontrol
    tofi
    mako
    wl-clipboard
    cliphist
    waybar
    swaybg
    rofi
    wofi
    mpd
    wdisplays
    jq
    bc
    swayimg
    swaylock-effects
    uv
    discord-ptb
    vscode-fhs
    bat
    slurp
    libnotify
    imagemagick
    libsixel
    zip
    unzip
    seahorse
    libsecret
    glib
    baobab
    tdf
    network_manager_ui
    swtchr
    maven
    javaPackages.compiler.openjdk21
    pinta
    (btop.override { cudaSupport = true; })
    snx-rs
    wl-mirror
    chromium
    gemini-cli
    ripgrep
    nixfmt
    fzf
    tree
    wf-recorder
    ffmpeg
    aseprite
    blender
    claude-code
    rtk
    nodejs_25
    
    # System-wide python packages 
    (python314.withPackages (ps: with ps; [
      pygobject3
    ]))

    gobject-introspection
    playerctl
  ];

  programs.wireshark.enable = true;
  programs.wireshark.package = pkgs.wireshark;

  programs.foot = {
    enable = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    configure = {
      customLuaRC = ''
        -- Function to clear backgrounds
        local function transparency()
          local highlights = {
            "Normal",
            "NormalNC",
            "LineNr",
            "Folded",
            "NonText",
            "SpecialKey",
            "VertSplit",
            "SignColumn",
            "EndOfBuffer",
          }
          for _, group in ipairs(highlights) do
            vim.api.nvim_set_hl(0, group, { bg = "none", ctermbg = "none" })
          end
        end

        -- Run it now
        transparency()
        
        -- Ensure it stays transparent even if you change colorschemes later
        vim.api.nvim_create_autocmd("ColorScheme", {
          pattern = "*",
          callback = transparency,
        })
      '';
    };
  };

  programs.bash = {
    enable = true;
    
    interactiveShellInit = ''
      bind 'set completion-ignore-case on'
      bind TAB:menu-complete
    '';
  };
  
  security.wrappers.btop = {
    owner = "root";
    group = "root";
    capabilities = "cap_sys_ptrace,cap_dac_read_search,cap_perfmon+ep";
    source = "${pkgs.btop.override { cudaSupport = true; }}/bin/btop";
  };

  security.pam.services = {
    greetd.enableGnomeKeyring = true;
    swaylock.enableGnomeKeyring = true;
    login.enableGnomeKeyring = true;
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  security.polkit = {
    enable = true;
    extraConfig = ''
      polkit.addRule(function(action, subject) {
        if ((action.id == "org.freedesktop.udisks2.filesystem-mount-system" ||
             action.id == "org.freedesktop.udisks2.filesystem-mount") &&
            subject.isInGroup("wheel")) {
          return polkit.Result.YES;
        }
      });
    '';
  };
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  services.envfs.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true; 
  services.gnome.gnome-keyring.enable = true;
  services.gnome.gcr-ssh-agent.enable = false;

  # This is needed because it sets up stuff to work
  programs.sway.enable = true;
  #programs.sway.wrapperFeatures.gtk = true;
  programs.sway.extraOptions = ["--unsupported-gpu"];
  programs.sway.package = pkgs.swayfx;
  
  programs.nm-applet.enable = true;
  programs.git = {
    enable = true;
    config = {
      init = {
        defaultBranch = "master";
      };
      url = {
        "https://github.com/" = {
          insteadOf = [
            "gh:"
            "github:"
          ];
        };
      };
    };
  };
 
  
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      nerd-fonts.fira-code
    ];
    enableDefaultPackages = true;
  };

  programs.ssh.startAgent = true;

  environment.variables = {
    TERMINAL = "foot";
  };
  
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    GI_TYPELIB_PATH = let
      basePackages = [ 
        pkgs.gobject-introspection 
        pkgs.playerctl 
      ];
    in
      pkgs.lib.makeSearchPathOutput "lib" "lib/girepository-1.0" basePackages;
  };

  virtualisation.docker.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Cenas do SNX
  systemd.services.snx-rs = {
    enable = true;
    path = [pkgs.iproute2 pkgs.kmod pkgs.networkmanager]; # for ip, modprobe and nmcli commands
    description = "SNX-RS VPN client for Linux";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
        ExecStart = "${pkgs.snx-rs}/bin/snx-rs -m command -l debug";
        Type = "simple";
    };
  };

  # update the firewall rule to allow keepalive traffic
  networking.firewall.checkReversePath = "loose";
  networking.firewall.trustedInterfaces = [ "snx-tun" ];
  networking.firewall.allowedUDPPorts = [ 500 4500 ];

  # Mudar de output de audio sem pausar 
  #services.pipewire = {
  #  enable = true;
  #  
  #  wireplumber.extraConfig."99-disable-pause" = {
  #    "wireplumber.settings" = {
  #      "linking.pause-playback" = false;
  #    };
  #  };
  #};

  services.libinput = {
    enable = true;
    touchpad = {
      tapping = true;
      tappingDragLock = false;
    };
  };

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
