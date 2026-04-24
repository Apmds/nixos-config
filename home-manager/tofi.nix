{config, pkgs, ...}:
{
  programs.tofi = {
    enable = true;

    settings = {
      # Size/spacing
      font-size = 14;
      padding-top = 15;
      padding-left = 30;
      corner-radius = 25;
      outline-width = 0;
      border-width = 3;
      width = 550;
      height = 600;

      # Settings
      fuzzy-match = true;
      drun-launch = true;
      terminal="foot";

      # Prompt/placeholder settings
      prompt-text = "Run: ";
      placeholder-text = "name...";
      placeholder-background-padding = "-1, 300, -1, -1";
      placeholder-background-corner-radius = 10;

      # Catppuccin Macchiato Colors
      text-color = "#cad3f5";
      prompt-color = "#c6a0f6";
      selection-color = "#eed49f";
      background-color = "#24273aF5";
      placeholder-color = "#8087a2";
      placeholder-background = "#1e2030";
      border-color = "#8aadf4";
      selection-background = "#363a4f";
    };
  };
}
