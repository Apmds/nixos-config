{config, pkgs, ...}:
{
  programs.starship = {
    enable = true;
    enableBashIntegration = true; 

    settings = {
      "$schema" = "'https://starship.rs/config-schema.json'";

      add_newline = true;

      format = ''
        $directory$git_branch$git_status$python$nix_shell
        $character'';

      directory = {
        format = "[$path]($style)";
        style = "blue";
        truncation_length = 0;
      };

      git_branch = {
        format = " \\( [$branch]($style)";
        style = "white";
      };

      git_status = {
        format = "$all_status$ahead_behind \\)";
        staged = " [+$count](green)";
        modified = " [~$count](yellow)";
        untracked = " [?$count](white)";
        deleted = " [-$count](red)";
        conflicted = " [!$count](red)";
        renamed = "";
        stashed = "";
        ahead = " [⇡$count](green)";
        behind = " [⇣$count](red)";
        diverged = " [⇡$ahead_count⇣$behind_count](yellow)";
        up_to_date = " [✓](green)";
      };

      # (venv name)
      python = {
        format = " \\([$virtualenv]($style)\\)";
        style = "bold cyan";
        detect_extensions = [ ];
        detect_files = [ ];
        detect_folders = [ ];
      };

      # (nix)
      nix_shell = {
        format = " [$symbol]($style)";
        symbol = "\\(nix\\)";
        style = "bold blue";
        heuristic = true;
      };

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };
    };
  };
}