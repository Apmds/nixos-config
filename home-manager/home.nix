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
 
  nixpkgs.config.allowUnfree = true;

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "apmds";
  home.homeDirectory = "/home/apmds";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/apmds/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    #EDITOR = "vim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  
  programs.bash.enable = true;

  # Custom desktop files
  xdg.desktopEntries = {
    whatsapp = {
      name = "Whatsapp";
      genericName = "Message";
      exec = "firefox -new-window https://web.whatsapp.com/";
      terminal = false;
      categories = [ "Network" "WebBrowser" ];
      mimeType = [ "text/html" "text/xml" ];
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "catppuccin-macchiato-mauve-standard+normal";
      package = pkgs.catppuccin-gtk.override {
        variant = "macchiato";
        accents = ["mauve"];
        size = "standard";
        tweaks = ["normal"];
      };
    };

    iconTheme = {
      name = "Papirus-Dark"; 
      package = pkgs.catppuccin-papirus-folders.override {
        flavor = "macchiato";
        accent = "mauve";
      };
    };

    gtk3.extraConfig = { gtk-application-prefer-dark-theme = 1; };
    gtk4.extraConfig = { gtk-application-prefer-dark-theme = 1; };
  };

  home.pointerCursor = {
    name = "Vanilla-DMZ";
    package = pkgs.vanilla-dmz;
    size = 24; # You can change this to 32, 48, or 64 if you prefer larger cursors
    gtk.enable = true;
    x11.enable = true;
  };

  xdg.configFile = {
    "gtk-4.0/assets".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
    "gtk-4.0/gtk.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
    "gtk-4.0/gtk-dark.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
  };
  
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  programs.starship = {
    enable = true;
    enableBashIntegration = true; 

    settings = {
      "$schema" = "'https://starship.rs/config-schema.json'";

      add_newline = true;

      format = ''
        $directory$git_branch$git_status$python$nix_shell
        $character'';

      directory = {
        format = "[$path]($style)";
        style = "blue";
        truncation_length = 0;
      };

      git_branch = {
        format = " \\( [$branch]($style)";
        style = "white";
      };

      git_status = {
        format = "$all_status$ahead_behind \\)";
        staged = " [+$count](green)";
        modified = " [~$count](yellow)";
        untracked = " [?$count](white)";
        deleted = " [-$count](red)";
        conflicted = " [!$count](red)";
        renamed = "";
        stashed = "";
        ahead = " [⇡$count](green)";
        behind = " [⇣$count](red)";
        diverged = " [⇡$ahead_count⇣$behind_count](yellow)";
        up_to_date = " [✓](green)";
      };

      # (venv name)
      python = {
        format = " \\([$virtualenv]($style)\\)";
        style = "bold cyan";
        detect_extensions = [ ];
        detect_files = [ ];
        detect_folders = [ ];
      };

      # (nix)
      nix_shell = {
        format = " [$symbol]($style)";
        symbol = "\\(nix\\)";
        style = "bold blue";
        heuristic = true;
      };

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };
    };
  };
  
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
