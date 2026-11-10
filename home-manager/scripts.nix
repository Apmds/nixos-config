{ pkgs }:

{
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

  swayScreenshot = pkgs.writeShellApplication {
    name = "sway-screenshot";
    runtimeInputs = [ pkgs.grim pkgs.slurp pkgs.wl-clipboard ];
    text = ''
      grim -g "$(slurp)" - | wl-copy
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

  powerProfile = pkgs.writeShellApplication {
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
}
