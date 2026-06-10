{ config, pkgs, ... }:
let
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

  powerProfileScript = pkgs.writeShellApplication {
    name = "power-profile";
    runtimeInputs = [ pkgs.power-profiles-daemon ];
    text = ''
      ICON_POWER_SAVER=""
      ICON_BALANCED="󰗑"
      ICON_PERFORMANCE="󱪉"

      current_profile=$(powerprofilesctl get)

      case "$current_profile" in
          power-saver)
              icon=$ICON_POWER_SAVER
              ;;
          balanced)
              icon=$ICON_BALANCED
              ;;
          performance)
              icon=$ICON_PERFORMANCE
              ;;
          *)
              icon="❓"
              ;;
      esac

      echo "{\"text\": \"$icon\", \"tooltip\": \"Profile: $current_profile\"}"
    '';
  };

  nordvpnStatus = pkgs.writeShellApplication {
    name = "nordvpn-status";
    runtimeInputs = [ pkgs.gnugrep pkgs.gawk ];
    text = ''
      status=$(nordvpn status | grep -i "Status" | awk '{print $2}')

      if [[ "$status" == "Connected" ]]; then
          echo '{"text": " VPN", "tooltip": "NordVPN Connected", "class": "connected"}'
      else
          echo '{"text": " VPN", "tooltip": "NordVPN Disconnected", "class": "disconnected"}'
      fi
    '';
  };

  nordvpnConnect = pkgs.writeShellApplication {
    name = "nordvpn-connect";
    runtimeInputs = [ pkgs.gnugrep pkgs.libnotify ];
    text = ''
      status=$(nordvpn status | grep "Status" | cut -d ':' -f 2 | tr -d ' ')

      if [ "$status" = "Connected" ]; then
              notify-send "Disconnecting from NordVPN"
              nordvpn disconnect
      fi

      if [ "$status" = "Disconnected" ]; then
              notify-send "Connecting to NordVPN"
              nordvpn connect
      fi
    '';
  };

  mediaPlayer = pkgs.writeShellApplication {
    name = "mediaplayer";
    runtimeInputs = [ 
      (pkgs.python3.withPackages (ps: with ps; [ pygobject3 ]))
      pkgs.playerctl
    ];
    text = ''
      python3 ${pkgs.writeText "mediaplayer.py" ''
        import gi
        gi.require_version("Playerctl", "2.0")
        from gi.repository import Playerctl, GLib
        from gi.repository.Playerctl import Player
        import argparse
        import logging
        import sys
        import signal
        import json
        import os
        from typing import List

        logger = logging.getLogger(__name__)

        def signal_handler(sig, frame):
            logger.info("Received signal to stop, exiting")
            sys.stdout.write("\n")
            sys.stdout.flush()
            # loop.quit()
            sys.exit(0)


        class PlayerManager:
            def __init__(self, selected_player=None, excluded_player=[]):
                self.manager = Playerctl.PlayerManager()
                self.loop = GLib.MainLoop()
                self.manager.connect(
                    "name-appeared", lambda *args: self.on_player_appeared(*args))
                self.manager.connect(
                    "player-vanished", lambda *args: self.on_player_vanished(*args))

                signal.signal(signal.SIGINT, signal_handler)
                signal.signal(signal.SIGTERM, signal_handler)
                signal.signal(signal.SIGPIPE, signal.SIG_DFL)
                self.selected_player = selected_player
                self.excluded_player = excluded_player.split(',') if excluded_player else []

                self.init_players()

            def init_players(self):
                for player in self.manager.props.player_names:
                    if player.name in self.excluded_player:
                        continue
                    if self.selected_player is not None and self.selected_player != player.name:
                        logger.debug(f"{player.name} is not the filtered player, skipping it")
                        continue
                    self.init_player(player)

            def run(self):
                logger.info("Starting main loop")
                self.loop.run()

            def init_player(self, player):
                logger.info(f"Initialize new player: {player.name}")
                player = Playerctl.Player.new_from_name(player)
                player.connect("playback-status",
                               self.on_playback_status_changed, None)
                player.connect("metadata", self.on_metadata_changed, None)
                self.manager.manage_player(player)
                self.on_metadata_changed(player, player.props.metadata)

            def get_players(self) -> List[Player]:
                return self.manager.props.players

            def write_output(self, text, player):
                logger.debug(f"Writing output: {text}")

                output = {"text": text,
                          "class": "custom-" + player.props.player_name,
                          "alt": player.props.player_name}

                sys.stdout.write(json.dumps(output) + "\n")
                sys.stdout.flush()

            def clear_output(self):
                sys.stdout.write("\n")
                sys.stdout.flush()

            def on_playback_status_changed(self, player, status, _=None):
                logger.debug(f"Playback status changed for player {player.props.player_name}: {status}")
                self.on_metadata_changed(player, player.props.metadata)

            def get_first_playing_player(self):
                players = self.get_players()
                logger.debug(f"Getting first playing player from {len(players)} players")
                if len(players) > 0:
                    # if any are playing, show the first one that is playing
                    # reverse order, so that the most recently added ones are preferred
                    for player in players[::-1]:
                        if player.props.status == "Playing":
                            return player
                    # if none are playing, show the first one
                    return players[0]
                else:
                    logger.debug("No players found")
                    return None

            def show_most_important_player(self):
                logger.debug("Showing most important player")
                # show the currently playing player
                # or else show the first paused player
                # or else show nothing
                current_player = self.get_first_playing_player()
                if current_player is not None:
                    self.on_metadata_changed(current_player, current_player.props.metadata)
                else:    
                    self.clear_output()

            def on_metadata_changed(self, player, metadata, _=None):
                logger.debug(f"Metadata changed for player {player.props.player_name}")
                player_name = player.props.player_name
                artist = player.get_artist()
                title = player.get_title()
                title = title.replace("&", "&amp;")

                track_info = ""
                if player_name == "spotify" and "mpris:trackid" in metadata.keys() and ":ad:" in player.props.metadata["mpris:trackid"]:
                    track_info = "Advertisement"
                elif artist is not None and title is not None:
                    track_info = f"{artist} - {title}"
                else:
                    track_info = title

                if track_info:
                    if player.props.status == "Playing":
                        track_info = " " + track_info
                    else:
                        track_info = " " + track_info
                # only print output if no other player is playing
                current_playing = self.get_first_playing_player()
                if current_playing is None or current_playing.props.player_name == player.props.player_name:
                    self.write_output(track_info, player)
                else:
                    logger.debug(f"Other player {current_playing.props.player_name} is playing, skipping")

            def on_player_appeared(self, _, player):
                logger.info(f"Player has appeared: {player.name}")
                if player.name in self.excluded_player:
                    logger.debug(
                        "New player appeared, but it's in exclude player list, skipping")
                    return
                if player is not None and (self.selected_player is None or player.name == self.selected_player):
                    self.init_player(player)
                else:
                    logger.debug(
                        "New player appeared, but it's not the selected player, skipping")

            def on_player_vanished(self, _, player):
                logger.info(f"Player {player.props.player_name} has vanished")
                self.show_most_important_player()

        def parse_arguments():
            parser = argparse.ArgumentParser()

            # Increase verbosity with every occurrence of -v
            parser.add_argument("-v", "--verbose", action="count", default=0)

            parser.add_argument("-x", "--exclude", help="Comma-separated list of excluded player")

            # Define for which player we"re listening
            parser.add_argument("--player")

            parser.add_argument("--enable-logging", action="store_true")

            return parser.parse_args()


        def main():
            arguments = parse_arguments()

            # Initialize logging
            if arguments.enable_logging:
                logfile = os.path.join(os.path.dirname(
                    os.path.realpath(__file__)), "media-player.log")
                logging.basicConfig(filename=logfile, level=logging.DEBUG,
                                    format="%(asctime)s %(name)s %(levelname)s:%(lineno)d %(message)s")

            # Logging is set by default to WARN and higher.
            # With every occurrence of -v it's lowered by one
            logger.setLevel(max((3 - arguments.verbose) * 10, 0))

            logger.info("Creating player manager")
            if arguments.player:
                logger.info(f"Filtering for player: {arguments.player}")
            if arguments.exclude:
                logger.info(f"Exclude player {arguments.exclude}")

            player = PlayerManager(arguments.player, arguments.exclude)
            player.run()


        if __name__ == "__main__":
            main()
      ''} "$@"
    '';
  };
in
{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        #layer = "top";
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
          exec = "${powerProfileScript}/bin/power-profile";
          on-click = "${cyclePowerProfiles}/bin/cycle-power-profiles";
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
          exec = "${mediaPlayer}/bin/mediaplayer"; # Script in resources folder
          #exec = "$HOME/.config/waybar/mediaplayer.py --player spotify 2> /dev/null"; # Filter player based on name
          on-click = "playerctl play-pause";
          on-scroll-up = "playerctl next";
          on-scroll-down = "playerctl previous";
        };

        "custom/power" = {
          format = "";
          tooltip = false;
          on-click = "${wofiPowermenu}/bin/wofi-powermenu";
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
          exec = "${nordvpnStatus}/bin/nordvpn-status";
          on-click = "${nordvpnConnect}/bin/nordvpn-connect";
          interval = 5;
          return-type = "json";
          tooltip = true;
        };

        "custom/powerprofiles" = {
          exec = "${powerProfileScript}/bin/power-profile";
          on-click = "${cyclePowerProfiles}/bin/cycle-power-profiles";
          interval = 5;
          return-type = "json";
          tooltip = true;
        };
      };
    };


    style = ''
      /* Catppuccin macchiato colors */
      @define-color rosewater #f4dbd6;
      @define-color flamingo #f0c6c6;
      @define-color pink #f5bde6;
      @define-color mauve #c6a0f6;
      @define-color red #ed8796;
      @define-color maroon #ee99a0;
      @define-color peach #f5a97f;
      @define-color yellow #eed49f;
      @define-color green #a6da95;
      @define-color teal #8bd5ca;
      @define-color sky #91d7e3;
      @define-color sapphire #7dc4e4;
      @define-color blue #8aadf4;
      @define-color lavender #b7bdf8;
      @define-color text #cad3f5;
      @define-color subtext1 #b8c0e0;
      @define-color subtext0 #a5adcb;
      @define-color overlay2 #939ab7;
      @define-color overlay1 #8087a2;
      @define-color overlay0 #6e738d;
      @define-color surface2 #5b6078;
      @define-color surface1 #494d64;
      @define-color surface0 #363a4f;
      @define-color base #24273a;
      @define-color mantle #1e2030;
      @define-color crust #181926;
      @define-color base_opacity rgba(36, 39, 58, 0.6);

      * {
        border: none;
        border-radius: 0;
        min-height: 0;
        font-family: JetBrainsMono Nerd Font;
        font-size: 13px;
        /*color: @text;*/
      }

      window#waybar {
        background-color: @base_opacity;
        /*color: #FFFFFF;*/
        transition-property: background-color;
        transition-duration: 0.5s;
      }

      window#waybar.hidden {
        opacity: 0.5;
      }

      #workspaces {
        background-color: transparent;
      }

      #workspaces button {
        all: initial;
        /* Remove GTK theme values (waybar #1351) */
        min-width: 0;
        /* Fix weird spacing in materia (waybar #450) */
        box-shadow: inset 0 -3px transparent;
        /* Use box-shadow instead of border so the text isn't offset */
        padding: 6px 18px;
        margin: 6px 3px;
        border-radius: 4px;
        background-color: @surface0;
        color: @text;
      }

      #workspaces button.active {
        color: @crust;
        background-color: @overlay2;
      }

      #workspaces button:hover {
        box-shadow: inherit;
        text-shadow: inherit;
        background-color: @surface1;
      }

      #workspaces button.focused {
          color: @crust;
          background-color: @overlay2;
      }

      #workspaces button.urgent {
        background-color: @red;
      }

      #memory,
      #custom-power,
      #custom-media,
      #custom-nordvpn,
      #custom-powerprofiles,
      #battery,
      #backlight,
      #wireplumber,
      #network,
      #clock,
      #language,
      #mode,
      #pulseaudio,
      #tray {
        border-radius: 4px;
        margin: 6px 3px;
        padding: 6px 12px;
        background-color: @flamingo;
        color: @crust;
      }

      #mode {
          background-color: @surface0;
          box-shadow: inset 0 -3px #f0f0ff;
          color: @text;
      }

      #custom-power {
        margin-right: 6px;
      }

      #custom-logo {
        padding-right: 7px;
        padding-left: 7px;
        margin-left: 5px;
        font-size: 15px;
        border-radius: 8px 0px 0px 8px;
        /*color: #1793d1;*/
      }

      #memory {
        background-color: @maroon;
      }

      #battery {
        background-color: @pink;
      }

      #battery.warning,
      #battery.critical,
      #battery.urgent {
        background-color: @red;
        /*color: @yellow;*/
      }

      #battery.charging {
        background-color: @green;
        /*color: #181825;*/
      }

      #backlight {
        background-color: @peach;
      }

      #wireplumber {
        background-color: @blue;
      }

      #network {
        background-color: @sapphire;
        padding-right: 17px;
      }

      #clock {
        font-family: JetBrainsMono Nerd Font;
        background-color: @mauve;
      }

      #custom-power {
        background-color: @flamingo;
      }


      #custom-nordvpn {
        background-color: @sky;
      }

      #custom-media {
        background-color: rgba(0, 0, 0, 0);
        color: #FFFFFF;
        min-width: 100px;
      }

      #custom-media.custom-spotify {
        color: #1DB954;                      /* Spotify color */
      }
      /*
      #custom-media.custom-spotify::first-letter {
        color: #1DB954;
      }
      */

      #custom-media.custom-vlc {
        background-color: #ffa000;
      }

      #language {
        background: @green;
        /*color: #000000;*/
      }

      #pulseaudio {
          background-color: @yellow;
          /*color: #000000;*/
      }

      #pulseaudio.muted {
          background-color: @lavender;
          /*color: #2a5c45;*/
      }

      tooltip {
        border-radius: 8px;
        padding: 15px;
        background-color: #131822;
      }

      tooltip label {
        padding: 5px;
        background-color: #131822;
      }
    '';
  };
}
