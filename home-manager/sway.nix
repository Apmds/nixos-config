{ config, lib, pkgs, sway-screenshot, ... }:
let
  toggleWaybar = pkgs.writeShellApplication {
    name = "toggle-waybar";
    runtimeInputs = [ pkgs.procps ];
    text = ''
      for PID in $(pgrep waybar); do
        kill -s SIGUSR1 "$PID"
      done
    '';
  };

  toggleRefreshRate = pkgs.writeShellApplication {
    name = "toggle-refresh-rate";
    runtimeInputs = [ pkgs.jq pkgs.bc pkgs.sway ];
    text = ''
      DEBOUNCE_FILE="/tmp/toggle_refresh_rate.lock"
      if [ -f "$DEBOUNCE_FILE" ]; then
        LAST_RUN=$(cat "$DEBOUNCE_FILE")
        CURRENT_TIME=$(date +%s)
        if (( CURRENT_TIME - LAST_RUN < 1 )); then
          exit 0
        fi
      fi
      date +%s > "$DEBOUNCE_FILE"
      MONITOR="eDP-1"
      CURRENT_RATE=$(swaymsg -t get_outputs | jq -r ".[] | select(.name == \"$MONITOR\") | .current_mode.refresh")
      NEW_RATE=0
      if [ "$CURRENT_RATE" -eq 60019 ]; then NEW_RATE=144003; fi
      if [ "$CURRENT_RATE" -eq 144003 ]; then NEW_RATE=60019; fi
      sleep 0.2
      swaymsg output "$MONITOR" mode 1920x1080@"$(bc -l <<< "$NEW_RATE/1000")"Hz
    '';
  };

  cyclePowerProfiles = pkgs.writeShellApplication {
    name = "cycle-power-profiles";
    runtimeInputs = [ pkgs.power-profiles-daemon pkgs.libnotify ];
    text = ''
      current_mode=$(powerprofilesctl get)
      modes=("power-saver" "balanced" "performance")
      current_index=0
      for i in "''${!modes[@]}"; do
        if [[ "''${modes[$i]}" == "$current_mode" ]]; then
          current_index=$i
          break
        fi
      done
      next_index=$(( (current_index + 1) % ''${#modes[@]} ))
      next_mode=''${modes[$next_index]}
      powerprofilesctl set "$next_mode"
      notify-send "Power Profile Switcher" "Switched from $current_mode to $next_mode"
    '';
  };

  lock = pkgs.writeShellApplication {
    name = "lock";
    runtimeInputs = [ pkgs.swayidle pkgs.swaylock pkgs.procps ];
    text = ''
      swayidle -w \
        timeout 15 'swaymsg "output * dpms off"' \
        resume 'swaymsg "output * dpms on"' &
      swaylock
      pkill --newest swayidle
    '';
  };

  swayScreenshot = pkgs.writeShellScriptBin "sway-screenshot"
    (builtins.readFile "${sway-screenshot}/sway-screenshot");

  wofiPowermenu = pkgs.writeShellApplication {
    name = "wofi-powermenu";
    runtimeInputs = [ pkgs.wofi pkgs.gawk ];
    text = ''
      entries="⇠ Logout\n⏾ Suspend\n⭮ Reboot\n⏻ Shutdown"
      selected=$(echo -e "$entries" | wofi --width 250 --height 240 --dmenu --cache-file /dev/null | awk '{print tolower($2)}')
      case $selected in
        logout)   exec sway exit ;;
        suspend)  exec systemctl suspend ;;
        reboot)   exec systemctl reboot ;;
        shutdown) exec systemctl poweroff ;;
      esac
    '';
  };
in
{
  imports = [
    ./tofi.nix
    ./wofi.nix
    ./waybar.nix
    ./mako.nix
    ./kanshi.nix
  ];

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
        "${modifier}+Shift+c" = "reload, exec systemctl --user restart kanshi";
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
        "${modifier}+Backspace" = "exec ${wofiPowermenu}/bin/wofi-powermenu";
        "${modifier}+Ctrl+Left" = "workspace prev";
        "${modifier}+Ctrl+Right" = "workspace next";
        "${modifier}+Ctrl+Shift+Left" = "move container to workspace prev";
        "${modifier}+Ctrl+Shift+Right" = "move container to workspace next";
        "${modifier}+Control+Alt+Right" = "move workspace to output right";
        "${modifier}+Control+Alt+Left" = "move workspace to output left";
        "${modifier}+Control+Alt+Down" = "move workspace to output down";
        "${modifier}+Control+Alt+Up" = "move workspace to output up";
        "${modifier}+Shift+s" = "exec ${swayScreenshot}/bin/sway-screenshot -m region --clipboard-only";
        "${modifier}+Shift+r" = "exec ${toggleRefreshRate}/bin/toggle-refresh-rate";
        "${modifier}+Shift+p" = "exec ${cyclePowerProfiles}/bin/cycle-power-profiles";
        "${modifier}+g" = "exec ${toggleWaybar}/bin/toggle-waybar";
        "${modifier}+t" = "exec network_manager_ui";
        "${modifier}+c" = "exec cliphist list | tofi -c $HOME/.config/tofi/config_clipboard | cliphist decode | wl-copy";
        "${modifier}+Tab" = "mode swtchr; exec swtchr";
        "${modifier}+Shift+Tab" = "mode swtchr; exec swtchr";

        "XF86MonBrightnessUp" = "exec brightnessctl s +5%";
        "XF86MonBrightnessDown" = "exec brightnessctl s 5%-";
        "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
        "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
        "XF86AudioMicMute" = "exec pactl set-source-mute @DEFAULT_SOURCE@ toggle";
        "Print" = "exec mkdir -p $HOME/Pictures/screenshots && grim $HOME/Pictures/screenshots/$(date +'%Y-%m-%d-%H%M%S').png";
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
          command = "swayidle -w timeout 600 '${lock}/bin/lock' timeout 630 'swaymsg \"output * dpms off\"' resume 'swaymsg \"output * dpms on\"' before-sleep '${lock}/bin/lock'";
        }
        { command = "sway-audio-idle-inhibit"; }
        { command = "swtchrd"; always = true; }
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
