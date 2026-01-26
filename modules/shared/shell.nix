{ lib, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ls = "eza --icons";
      ll = "eza -la --icons";
      cat = "bat";
      cd = "z";
      g = "git";
      gs = "git status";
      gd = "git diff";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";
    };
    initContent = lib.mkOrder 550 ''
      eval "$(zoxide init zsh)"
      eval "$(thefuck --alias)"
    '';
  };
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      format = "$username$hostname$directory$git_branch$git_status$nix_shell$character";
      character = {
        error_symbol = "[➜](bold #e67e80)";
        success_symbol = "[➜](bold #a7c080)";
      };
      directory = {
        style = "bold #7fbbb3";
        truncate_to_repo = true;
        truncation_length = 3;
      };
      git_branch = {
        style = "bold #d699b6";
        symbol = " ";
      };
      git_status = {
        style = "bold #dbbc7f";
      };
      nix_shell = {
        format = "via [$symbol$state]($style) ";
        style = "bold #7fbbb3";
        symbol = " ";
      };
    };
  };
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    colors = {
      bg = "#2d353b";
      "bg+" = "#475258";
      fg = "#d3c6aa";
      "fg+" = "#d3c6aa";
      hl = "#a7c080";
      "hl+" = "#a7c080";
      info = "#dbbc7f";
      marker = "#e67e80";
      prompt = "#7fbbb3";
      spinner = "#83c092";
      pointer = "#d699b6";
      header = "#83c092";
    };
  };
  programs.bat = {
    enable = true;
    config = {
      theme = "everforest";
      pager = "less -FR";
    };
  };
}
