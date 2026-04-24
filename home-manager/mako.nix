{ config, lib, pkgs, ... }:
{
  services.mako = {
    enable = true;

    settings = {
      font="Cozette 11";
      format="<b>%a ⏵</b> %s\n%b";
      sort="-time";
      output="DP-2";
      layer="overlay";
      anchor="top-right";
      background-color="#1e242f";
      width=300;
      height=110;
      margin=5;
      padding="5,5,10";
      border-size=5;
      border-color="#2c9fb5";
      border-radius=20;
      max-icon-size=64;
      default-timeout=2000;
      ignore-timeout=1;

      "urgency=high" = {
        default-timeout=0;
      };
    };
  };
}