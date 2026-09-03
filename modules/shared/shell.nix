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
      cat = "bat --paging=never";
      cd = "z";
      g = "git";
      gs = "git status";
      gd = "git diff";
      gc = "git commit";
      sc = "sconnect";
      gp = "git push";
      gl = "git pull";
    };
    sessionVariables = {
      NPM_CONFIG_PREFIX = "$HOME/.npm-global";
    };
    initContent = lib.mkOrder 550 ''
      eval "$(zoxide init zsh)"
      eval "$(pay-respects zsh --alias)"
      export PATH="$HOME/.npm-global/bin:$PATH"
      export PATH="$HOME/.local/bin:$PATH"
      FPATH="$HOME/.docker/completions:$FPATH"
      autoload -Uz compinit
      compinit
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
        error_symbol = "[➜](bold #305561)";
        success_symbol = "[➜](bold #116FAE)";
      };
      directory = {
        style = "bold #116FAE";
        truncate_to_repo = true;
        truncation_length = 3;
      };
      git_branch = {
        style = "bold #68A2C6";
        symbol = " ";
      };
      git_status = {
        style = "bold #7E8A94";
      };
      nix_shell = {
        format = "via [$symbol$state]($style) ";
        style = "bold #06467E";
        symbol = " ";
      };
    };
  };
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    colors = {
      bg = "#04182F";
      "bg+" = "#06467E";
      fg = "#68A2C6";
      "fg+" = "#68A2C6";
      hl = "#116FAE";
      "hl+" = "#116FAE";
      info = "#7E8A94";
      marker = "#305561";
      prompt = "#116FAE";
      spinner = "#68A2C6";
      pointer = "#68A2C6";
      header = "#305561";
    };
  };
  programs.bat = {
    enable = true;
    config = {
      theme = "base16";
      pager = "less -FR";
    };
  };
}
