{config, pkgs, ...}:

{
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

    "org/cinnamon/desktop/default-applications/terminal" = {
      exec = "foot";
      exec-arg = "";
    };
  
    "org/gnome/desktop/default-applications/terminal" = {
      exec = "foot";
      exec-arg = ""; 
    };
  };

  xdg.terminal-exec = {
    enable = true;
    settings = {
      default = [ "foot.desktop" ];
    };
  };

  xdg.dataFile."nemo/actions/foot.nemo_action".text = ''
    [Nemo Action]
    Active=true
    Name=Open in Foot
    Comment=Open Foot terminal here
    Exec=foot -D "%P"
    Icon-Name=utilities-terminal
    Selection=none
    Extensions=any;
  '';
}

