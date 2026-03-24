{ config, pkgs, ... }:
{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        spacing = 4;

        modules-left = [
          "sway/workspaces"
          "sway/mode"
          "sway/language"
          "sway/scratchpad"
        ];

        modules-center = [
          "sway/window"
        ];

        modules-right = [
          #"mpd"
          #"idle_inhibitor"
          "network"
          #"custom/nordvpn"
          "custom/powerprofiles"
          #"cpu"
          #"memory"
          #"temperature"
          "backlight"
          #"keyboard-state"
          "pulseaudio"
          "battery"
          "clock"
          #"tray"
          "custom/power"
        ];

        "sway/workspaces" = {
          "window-rewrite" = { };
          "disable-scroll" = true;
          #"all-outputs" = true,
          #"warp-on-scroll" = false,
          #"format" = "{name}: {icon}",
          #"format-icons" = {
          #"1" = "",
          #"2" = "",
          #"3" = "",
          #"4" = "",
          #"5" = "",
          #"urgent" = "",
          #"focused" = "",
          #"default" = ""
          #}
        };

        keyboard-state = {
          "numlock" = true;
          "capslock" = true;
          "format" = "{name} {icon}";
          "format-icons" = {
            "locked" = "";
            "unlocked" = "";
          };
        };

        "sway/mode" = {
          "format" = "<span style=\"italic\">{}</span>";
        };

        "sway/scratchpad" = {
          "format" = "{icon} {count}";
          "show-empty" = false;
          "format-icons" = [
            ""
            ""
          ];
          "tooltip" = true;
          "tooltip-format" = "{app}: {title}";
        };

        "sway/window" = {
          "format" = "{title}";
          "max-length" = 90;
        };

        mpd = {
          "format" =
            "{stateIcon} {consumeIcon}{randomIcon}{repeatIcon}{singleIcon}{artist} - {album} - {title} ({elapsedTime:%M:%S}/{totalTime:%M:%S}) ⸨{songPosition}|{queueLength}⸩ {volume}% ";
          "format-disconnected" = "Disconnected ";
          "format-stopped" = "{consumeIcon}{randomIcon}{repeatIcon}{singleIcon}Stopped ";
          "unknown-tag" = "N/A";
          "interval" = 5;
          "consume-icons" = {
            "on" = " ";
          };
          "random-icons" = {
            "off" = "<span color=\"#f53c3c\"></span> ";
            "on" = " ";
          };
          "repeat-icons" = {
            "on" = " ";
          };
          "single-icons" = {
            "on" = "1 ";
          };
          "state-icons" = {
            "paused" = "";
            "playing" = "";
          };
          "tooltip-format" = "MPD (connected)";
          "tooltip-format-disconnected" = "MPD (disconnected)";
        };

        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "";
            deactivated = "";
          };
        };
        tray = {
          #icon-size = 21;
          spacing = 10;
        };
        clock = {
          #timezone = "America/New_York";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          format-alt = "{:%d-%m-%Y}";
        };
        cpu = {
          format = "{usage}% ";
          tooltip = false;
        };
        memory = {
          format = "{}% ";
        };
        temperature = {
          #thermal-zone = 2;
          #hwmon-path = "/sys/class/hwmon/hwmon2/temp1_input";
          critical-threshold = 80;
          #format-critical = "{temperatureC}°C {icon}";
          format = "{temperatureC}°C {icon}";
          format-icons = [
            ""
            ""
            ""
          ];
        };
        backlight = {
          #device = "acpi_video1";
          format = "{percent}% {icon}";
          format-icons = [
            "󰃜"
            "󰃛"
            ""
            "󰓠"
            ""
          ];
          #format-icons = ["" "" "" "" "" "" "" "" ""];
        };

        battery = {
          states = {
            #good = 95;
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          format-full = "{capacity}% {icon}";
          format-charging = "{capacity}% 󰂄";
          format-plugged = "{capacity}% ";
          format-alt = "{time} {icon}";
          #format-good = ""; # An empty format will hide the module
          #format-full = "";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
          ];
        };
        "battery#bat2" = {
          bat = "BAT2";
        };
        power-profiles-daemon = {
          "format" = "{icon}";
          "tooltip-format" = "Power profile: {profile}\nDriver: {driver}";
          "tooltip" = true;
          "format-icons" = {
            "default" = "";
            "performance" = "";
            "balanced" = "";
            "power-saver" = "";
          };
        };

        network = {
          interface = "wlo1";
          format = "{ifname}";
          on-click = "network_manager_ui";
          format-wifi = "{essid} ({signalStrength}%) ";
          format-ethernet = "{ipaddr}/{cidr} 󰊗";
          format-disconnected = "Disconnected ⚠"; # An empty format will hide the module.
          tooltip-format = "{ifname} via {gwaddr} 󰊗";
          tooltip-format-wifi = "{essid} ({signalStrength}%) ";
          tooltip-format-ethernet = "{ifname} ";
          tooltip-format-disconnected = "Disconnected";
          max-length = 50;
        };
        pulseaudio = {
          #scroll-step = 1, # %, can be a float
          format = "{volume}% {icon} {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = " {icon} {format_source}";
          format-muted = " {format_source}";

          format-source = "{volume}% ";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            handsfree = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [
              ""
              ""
              ""
            ];
          };
          on-click = "pavucontrol";
        };

        "custom/powerprofile" = {
          format = "{}";
          exec = "~/.config/waybar/scripts/powerprofile.sh";
          on-click = "~/.config/waybar/scripts/cycle_powerprofile.sh";
          interval = 5;
        };

        "custom/media" = {
          format = "{icon} {text}";
          return-type = "json";
          max-length = 40;
          format-icons = {
            spotify = "";
            default = "🎜";
          };
          escape = true;
          #interval = 0;
          exec = "$HOME/.config/waybar/scripts/mediaplayer.py"; # Script in resources folder
          #exec = "$HOME/.config/waybar/mediaplayer.py --player spotify 2> /dev/null"; # Filter player based on name
          on-click = "playerctl play-pause";
          on-scroll-up = "playerctl next";
          on-scroll-down = "playerctl previous";
        };

        "custom/power" = {
          format = "";
          tooltip = false;
          on-click = "$HOME/.config/waybar/scripts/wofi-powermenu.sh";
          #menu = "on-click";
          #menu-file = "$HOME/.config/waybar/scripts/power_menu.xml"; # Menu file in resources folder
          #menu-actions = {
          #  shutdown = "shutdown";
          #  reboot = "reboot";
          #  suspend = "systemctl suspend && $HOME/.config/sway/scripts/lock.sh";
          #  hibernate = "systemctl hibernate";
          #};
        };

        "custom/nordvpn" = {
          exec = "~/.config/waybar/scripts/nordvpn-status.sh";
          on-click = "~/.config/waybar/scripts/nordvpn-connect.sh";
          interval = 5;
          return-type = "json";
          tooltip = true;
        };

        "custom/powerprofiles" = {
          exec = "~/.config/waybar/scripts/power-profile.sh";
          on-click = "~/.config/sway/scripts/cycle_power_profiles.sh";
          interval = 5;
          return-type = "json";
          tooltip = true;
        };
      };
    };
  };
}
