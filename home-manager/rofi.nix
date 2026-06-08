{ config, pkgs, ... }:
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;

    font = "JetBrainsMono Nerd Font 12";
    terminal = "${pkgs.foot}/bin/foot";

    extraConfig = {
      show-icons = true;
      drun-display-format = "{name}";
      icon-theme = "Papirus-Dark";
      display-drun = "Apps";
      display-run = "Run";
      display-window = "Windows";
    };

    theme = let
      inherit (config.lib.formats.rasi) mkLiteral;
    in {
      "*" = {
        bg0 = mkLiteral "#24273a";     # base
        bg1 = mkLiteral "#1e2030";     # mantle
        bg2 = mkLiteral "#363a4f";     # surface0
        bg3 = mkLiteral "#494d64";     # surface1
        fg0 = mkLiteral "#cad3f5";     # text
        fg1 = mkLiteral "#b8c0e0";     # subtext1
        accent = mkLiteral "#c6a0f6";  # mauve
        urgent = mkLiteral "#ed8796";  # red

        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@fg0";
      };

      window = {
        background-color = mkLiteral "@bg0";
        border = mkLiteral "2px solid";
        border-color = mkLiteral "@accent";
        border-radius = mkLiteral "8px";
        width = mkLiteral "600px";
        padding = mkLiteral "12px";
      };

      mainbox = {
        background-color = mkLiteral "transparent";
        spacing = mkLiteral "8px";
      };

      inputbar = {
        background-color = mkLiteral "@bg2";
        border-radius = mkLiteral "6px";
        padding = mkLiteral "8px 12px";
        spacing = mkLiteral "8px";
        children = map mkLiteral [ "prompt" "entry" ];
      };

      prompt = {
        text-color = mkLiteral "@accent";
        font = "JetBrainsMono Nerd Font Bold 12";
      };

      entry = {
        text-color = mkLiteral "@fg0";
        placeholder-color = mkLiteral "@fg1";
        placeholder = "Search...";
      };

      listview = {
        background-color = mkLiteral "transparent";
        lines = 8;
        columns = 1;
        spacing = mkLiteral "4px";
        scrollbar = false;
      };

      element = {
        background-color = mkLiteral "transparent";
        border-radius = mkLiteral "6px";
        padding = mkLiteral "8px 12px";
        spacing = mkLiteral "8px";
      };

      "element selected" = {
        background-color = mkLiteral "@bg3";
        text-color = mkLiteral "@accent";
      };

      "element urgent" = {
        text-color = mkLiteral "@urgent";
      };

      element-icon = {
        size = mkLiteral "20px";
      };

      element-text = {
        text-color = mkLiteral "inherit";
        vertical-align = mkLiteral "0.5";
      };
    };
  };
}
