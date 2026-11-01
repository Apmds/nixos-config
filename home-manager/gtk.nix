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
    gtk4.theme = config.gtk.theme;
  };

  home.pointerCursor = {
    enable = true;
    name = "Vanilla-DMZ";
    package = pkgs.vanilla-dmz.overrideAttrs (old: {
      postInstall = (old.postInstall or "") + ''
        for theme in DMZ-Black DMZ-White; do
          dir="$out/share/icons/$theme/cursors"
          if [ -d "$dir" ]; then
            # Horizontal resize / stretch
            ln -sf sb_h_double_arrow "$dir/ew-resize"
            ln -sf sb_h_double_arrow "$dir/col-resize"
            ln -sf sb_h_double_arrow "$dir/split_h"
            ln -sf sb_h_double_arrow "$dir/size_hor"
            ln -sf sb_h_double_arrow "$dir/size-hor"

            # Vertical resize / stretch
            ln -sf sb_v_double_arrow "$dir/ns-resize"
            ln -sf sb_v_double_arrow "$dir/row-resize"
            ln -sf sb_v_double_arrow "$dir/split_v"
            ln -sf sb_v_double_arrow "$dir/size_ver"
            ln -sf sb_v_double_arrow "$dir/size-ver"

            # Diagonal resize
            ln -sf fd_double_arrow "$dir/nesw-resize"
            ln -sf fd_double_arrow "$dir/size_fdiag"
            ln -sf fd_double_arrow "$dir/size-fdiag"

            ln -sf bd_double_arrow "$dir/nwse-resize"
            ln -sf bd_double_arrow "$dir/size_bdiag"
            ln -sf bd_double_arrow "$dir/size-bdiag"

            # All direction resize / move
            ln -sf fleur "$dir/all-resize"
            ln -sf fleur "$dir/all-scroll"
            ln -sf fleur "$dir/size_all"

            # Pointer, grab, text
            ln -sf hand2 "$dir/pointer"
            ln -sf hand2 "$dir/grab"
            ln -sf xterm "$dir/text"
            ln -sf xterm "$dir/vertical-text"
          fi

          themeFile="$out/share/icons/$theme/index.theme"
          if [ -f "$themeFile" ]; then
            sed -i "/^\[Icon Theme\]/a Inherits=Adwaita" "$themeFile"
          fi
        done
      '';
    });
    size = 24; # You can change this to 32, 48, or 64 if you prefer larger cursors
    gtk.enable = true;
    x11.enable = true;
    sway.enable = true;
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

