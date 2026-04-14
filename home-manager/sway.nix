{ config, lib, pkgs, ... }:
{
  services.poweralertd.enable = true;

  wayland.windowManager.sway = {
    enable = true;
    package = pkgs.swayfx;
    checkConfig = false;
    wrapperFeatures.gtk = true;
    systemd.variables = [ "--all" ];

    extraOptions = [ "--unsupported-gpu" ];

    config = rec {
      modifier = "Mod4";
      terminal = "foot";
      menu = "tofi-drun";

      keybindings = {
        "${modifier}+Return" = "exec ${terminal}";
        "${modifier}+Shift+q" = "kill";
        "${modifier}+d" = "exec ${menu}";
        "${modifier}+Shift+c" = "reload";
        "${modifier}+Shift+e" = "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -B 'Yes, exit sway' 'swaymsg exit'";

        "${modifier}+h" = "focus left";
        "${modifier}+j" = "focus down";
        "${modifier}+k" = "focus up";
        "${modifier}+l" = "focus right";
        "${modifier}+Left" = "focus left";
        "${modifier}+Down" = "focus down";
        "${modifier}+Up" = "focus up";
        "${modifier}+Right" = "focus right";

        "${modifier}+Shift+h" = "move left";
        "${modifier}+Shift+j" = "move down";
        "${modifier}+Shift+k" = "move up";
        "${modifier}+Shift+l" = "move right";
        "${modifier}+Shift+Left" = "move left";
        "${modifier}+Shift+Down" = "move down";
        "${modifier}+Shift+Up" = "move up";
        "${modifier}+Shift+Right" = "move right";

        "${modifier}+1" = "workspace number 1";
        "${modifier}+2" = "workspace number 2";
        "${modifier}+3" = "workspace number 3";
        "${modifier}+4" = "workspace number 4";
        "${modifier}+5" = "workspace number 5";
        "${modifier}+6" = "workspace number 6";
        "${modifier}+7" = "workspace number 7";
        "${modifier}+8" = "workspace number 8";
        "${modifier}+9" = "workspace number 9";
        "${modifier}+0" = "workspace number 10";

        "${modifier}+Shift+1" = "move container to workspace number 1";
        "${modifier}+Shift+2" = "move container to workspace number 2";
        "${modifier}+Shift+3" = "move container to workspace number 3";
        "${modifier}+Shift+4" = "move container to workspace number 4";
        "${modifier}+Shift+5" = "move container to workspace number 5";
        "${modifier}+Shift+6" = "move container to workspace number 6";
        "${modifier}+Shift+7" = "move container to workspace number 7";
        "${modifier}+Shift+8" = "move container to workspace number 8";
        "${modifier}+Shift+9" = "move container to workspace number 9";
        "${modifier}+Shift+0" = "move container to workspace number 10";

        "${modifier}+b" = "splith";
        "${modifier}+v" = "splitv";
        "${modifier}+s" = "layout stacking";
        "${modifier}+w" = "layout tabbed";
        "${modifier}+e" = "layout toggle split";
        "${modifier}+f" = "fullscreen";
        "${modifier}+Shift+space" = "floating toggle";
        "${modifier}+space" = "focus mode_toggle";
        "${modifier}+a" = "focus parent";
        "${modifier}+y" = "sticky toggle";

        "${modifier}+Shift+minus" = "move scratchpad";
        "${modifier}+minus" = "scratchpad show";

        "${modifier}+r" = "mode resize";
        "${modifier}+Insert" = "exec swaylock -i ~/Pictures/wallpapers/pixel_night_sky.png";
        "${modifier}+Backspace" = "exec $HOME/.config/waybar/scripts/wofi-powermenu.sh";
        "${modifier}+Ctrl+Left" = "workspace prev";
        "${modifier}+Ctrl+Right" = "workspace next";
        "${modifier}+Ctrl+Shift+Left" = "move container to workspace prev";
        "${modifier}+Ctrl+Shift+Right" = "move container to workspace next";
        "${modifier}+Control+Alt+Right" = "move workspace to output right";
        "${modifier}+Control+Alt+Left" = "move workspace to output left";
        "${modifier}+Control+Alt+Down" = "move workspace to output down";
        "${modifier}+Control+Alt+Up" = "move workspace to output up";
        "${modifier}+Shift+s" = "exec $HOME/.config/sway/scripts/sway-screenshot -m region --clipboard-only";
        "${modifier}+Shift+r" = "exec $HOME/.config/sway/scripts/toggle_refresh_rate.sh";
        "${modifier}+Shift+p" = "exec $HOME/.config/sway/scripts/cycle_power_profiles.sh";
        "${modifier}+g" = "exec $HOME/.config/sway/scripts/toggle_waybar.sh";
        "${modifier}+t" = "exec network_manager_ui";
        "${modifier}+c" = "exec cliphist list | tofi -c $HOME/.config/tofi/config_clipboard | cliphist decode | wl-copy";
        "${modifier}+Tab" = "mode swtchr; exec ~/.cargo/bin/swtchr";
        "${modifier}+Shift+Tab" = "mode swtchr; exec ~/.cargo/bin/swtchr";

        "XF86MonBrightnessUp" = "exec brightnessctl s +5%";
        "XF86MonBrightnessDown" = "exec brightnessctl s 5%-";
        "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
        "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
        "XF86AudioMicMute" = "exec pactl set-source-mute @DEFAULT_SOURCE@ toggle";
      };

      floating = {
        modifier = "${modifier} normal";
        border = 3;
        titlebar = false;
      };

      gaps = {
        inner = 5;
        outer = 2;
      };

      bars = [
        {
          command = "waybar";
        }
      ];

      window = {
        border = 3;
        titlebar = false;
        commands = [
          {
            command = "floating enable";
            criteria = {
              title = "Volume Control";
            };
          }
          {
            command = "floating enable, sticky enable";
            criteria = {
              title = "Picture-in-Picture";
            };
          }
        ];
      };

      input = {
        "type:touchpad" = {
          tap = "enabled";
          natural_scroll = "enabled";
          drag = "enabled";
          drag_lock = "disabled";
        };

        "type:keyboard" = {
          xkb_layout = "pt,pt(nodeadkeys)";
          xkb_options = "grp:alt_shift_toggle";
        };
      };

      output = {
        "*" = {
          mode = "1920x1080@144.003Hz";
          bg = "~/Pictures/wallpapers/eletric_poles_dusk.jpg stretch";
        };
      };

      modes = {
        resize = {
          h = "resize shrink width 10px";
          j = "resize grow height 10px";
          k = "resize shrink height 10px";
          l = "resize grow width 10px";
          Left = "resize shrink width 10px";
          Down = "resize grow height 10px";
          Up = "resize shrink height 10px";
          Right = "resize grow width 10px";
          Return = "mode default";
          Escape = "mode default";
        };

        swtchr = {
          Backspace = "mode default";
        };
      };

      startup = [
        { command = "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway"; }
        { command = "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"; }
        { command = "gnome-keyring-daemon --start --components=secrets,pkcs11"; }
        { command = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"; }
        #{ command = "poweralertd -s -i 'line power'"; }
        { command = "wl-paste --watch cliphist store"; }
        {
          command = "swayidle -w timeout 600 '$HOME/.config/sway/scripts/lock.sh' timeout 630 'swaymsg \"output * dpms off\"' resume 'swaymsg \"output * dpms on\"' before-sleep '$HOME/.config/sway/scripts/lock.sh'";
        }
        { command = "sway-audio-idle-inhibit"; }
        { command = "~/.cargo/bin/swtchrd"; always = true; }
      ];
    };

    extraConfig = ''
      include "$HOME/.cache/wal/colors-sway"
      include /etc/sway/config-vars.d/*
      include catppuccin-macchiato
      include /etc/sway/config.d/*

      default_border pixel 3
      default_floating_border pixel 3
      font pango:monospace 0.001
      titlebar_padding 1
      titlebar_border_thickness 0

      bindgesture swipe:right workspace prev
      bindgesture swipe:left workspace next

      corner_radius 10
      blur enable
      blur_passes 1
      blur_radius 1
      default_dim_inactive 0.1

      workspace number 1
    '';
  };
}
