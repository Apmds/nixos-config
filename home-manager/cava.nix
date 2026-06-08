{ config, pkgs, ... }:
{
  programs.cava = {
    enable = true;

    settings = {
      general = {
        framerate = 60;
        bars = 0;
        bar_width = 2;
        bar_spacing = 1;
        bar_height = 32;
      };

      input = {
        method = "pulse";
      };

      output = {
        method = "ncurses";
        channels = "stereo";
      };

      color = {
        gradient = 1;
        gradient_count = 8;
        gradient_color_1 = "'#b7bdf8'"; # lavender
        gradient_color_2 = "'#c6a0f6'"; # mauve
        gradient_color_3 = "'#f5bde6'"; # pink
        gradient_color_4 = "'#f0c6c6'"; # flamingo
        gradient_color_5 = "'#ed8796'"; # red
        gradient_color_6 = "'#f5a97f'"; # peach
        gradient_color_7 = "'#eed49f'"; # yellow
        gradient_color_8 = "'#a6da95'"; # green
        background = "'#24273a'"; # base
      };

      smoothing = {
        noise_reduction = 77;
      };
    };
  };
}
