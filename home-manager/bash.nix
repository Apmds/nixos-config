{config, pkgs, ... }:
{
  imports = [
    ./starship.nix
  ];

  programs.bash = {
    enable = true;

    shellAliases = {
      py="python3";
      penv="source env/bin/activate 2>/dev/null || source venv/bin/activate 2>/dev/null || source .venv/bin/activate 2>/dev/null || source .env/bin/activate 2>/dev/null";
      cls="clear";
      bat="bat --theme 'Catppuccin Macchiato'";
      openf="xdg-open $(fzf --preview \"bat --theme '\''Catppuccin Macchiato'\'' --color=always {}\" --preview-window \"~3\")";

    #cdf='find . -type d -print | fzf -i';
      cdf="cd \"$(find . -type d -print | fzf -i)\"";
      togglerefresh="~/.config/sway/scripts/toggle_refresh_rate.sh";
      vpn="snxctl";

      AED="cd ~/UA/2o_ano/1o_semestre/AED/";
      MPEI="cd ~/UA/2o_ano/1o_semestre/MPEI/";
      RS="cd ~/UA/2o_ano/1o_semestre/RS/";
      SM="cd ~/UA/2o_ano/1o_semestre/SM/";
      SO="cd ~/UA/2o_ano/1o_semestre/SO/";

      C="cd ~/UA/2o_ano/2o_semestre/C/";
      PDS="cd ~/UA/2o_ano/2o_semestre/P;DS/";
      IHC="cd ~/UA/2o_ano/2o_semestre/I;HC/";
      BD="cd ~/UA/2o_ano/2o_semestre/BD/";
      CD="cd ~/UA/2o_ano/2o_semestre/CD/";

      IA="cd ~/UA/3o_ano/1o_semestre/IA/";
      TQS="cd ~/UA/3o_ano/1o_semestre/TQS/";
      SIO="cd ~/UA/3o_ano/1o_semestre/SIO/";
      PEI="cd ~/UA/3o_ano/PEI/";
      CT="cd ~/UA/3o_ano/1o_semestre/CT/";

      CBD="cd ~/UA/3o_ano/2o_semestre/CBD/";
      ICG="cd ~/UA/3o_ano/2o_semestre/ICG/";
      IAA="cd ~/UA/3o_ano/2o_semestre/IAA/";
      IES="cd ~/UA/3o_ano/2o_semestre/IES/";

      kys="poweroff";
      horario="img2sixel ~/Pictures/horarios/horario_3a2s.png";

      ports="sudo ss -tulpn";
      nixfetch="fastfetch --logo ~/.config/nixos_neofetch_logo.txt --logo-color-1 blue --logo-color-2 cyan";
    };
  };
}