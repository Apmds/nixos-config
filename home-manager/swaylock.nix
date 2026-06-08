{ config, pkgs, ... }:
{
  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;

    settings = {
      daemonize = true;
      show-failed-attempts = true;
      ignore-empty-password = true;

      image = "/home/apmds/Pictures/wallpapers/pixel_night_sky.png";

      clock = true;
      indicator = true;

      color = "24273a";
      bs-hl-color = "f4dbd6";
      caps-lock-bs-hl-color = "f4dbd6";
      caps-lock-key-hl-color = "a6da95";
      inside-color = "00000099";
      inside-clear-color = "00000099";
      inside-caps-lock-color = "00000099";
      inside-ver-color = "00000099";
      inside-wrong-color = "00000099";
      key-hl-color = "a6da95";
      layout-bg-color = "00000099";
      layout-border-color = "00000099";
      layout-text-color = "cad3f5";
      line-color = "000000";
      line-clear-color = "000000";
      line-caps-lock-color = "000000";
      line-ver-color = "000000";
      line-wrong-color = "000000";
      ring-color = "b7bdf8";
      ring-clear-color = "f4dbd6";
      ring-caps-lock-color = "f5a97f";
      ring-ver-color = "8aadf4";
      ring-wrong-color = "ee99a0";
      separator-color = "00000000";
      text-color = "cad3f5";
      text-clear-color = "f4dbd6";
      text-caps-lock-color = "f5a97f";
      text-ver-color = "8aadf4";
      text-wrong-color = "ee99a0";
    };
  };
}
