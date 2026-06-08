{config, lib, pkgs, ...}:
{
  services.kanshi = {
    enable = true;
    settings = [
      {
        profile.name = "01_home";
        profile.outputs = [
          {
            criteria = "ASUSTek COMPUTER INC XG27AQDMGR W1LMTF016546";
            mode = "2560x1440@59.951";
            position = "0,0";
            status = "enable";
          }
          {
            criteria = "eDP-1";
            position = "0,1440";
            status = "enable";
          }
        ];
      }
      {
        profile.name = "02_base";
        profile.outputs = [
          {
            criteria = "HDMI-A-1";
            mode = "1920x1080@60.000";
            position = "0,0";
            status = "enable";
          }
          {
            criteria = "eDP-1";
            position = "0,1080";
            status = "enable";
          }
        ];
      }
    ];
  };
}
