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
      gp = "git push";
      gl = "git pull";
    };
    sessionVariables = {
      NPM_CONFIG_PREFIX = "$HOME/.npm-global";
    };
    initContent = lib.mkOrder 550 ''
      eval "$(zoxide init zsh)"
      eval "$(thefuck --alias)"
      export PATH="$HOME/.npm-global/bin:$PATH"
      export PATH="$HOME/Developer/abyssal/.venv/bin:$PATH"
      export PATH="$HOME/Developer/i2p-easy-manager/venv/bin:$PATH"
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
        error_symbol = "[➜](bold #7090b8)";
        success_symbol = "[➜](bold #5ba3c9)";
      };
      directory = {
        style = "bold #4f8fbf";
        truncate_to_repo = true;
        truncation_length = 3;
      };
      git_branch = {
        style = "bold #8eafd4";
        symbol = " ";
      };
      git_status = {
        style = "bold #a8c8e8";
      };
      nix_shell = {
        format = "via [$symbol$state]($style) ";
        style = "bold #4f8fbf";
        symbol = " ";
      };
    };
  };
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    colors = {
      bg = "#0d1b2a";
      "bg+" = "#1b2d42";
      fg = "#cdd9e5";
      "fg+" = "#cdd9e5";
      hl = "#5ba3c9";
      "hl+" = "#5ba3c9";
      info = "#a8c8e8";
      marker = "#7090b8";
      prompt = "#4f8fbf";
      spinner = "#6ec6c6";
      pointer = "#8eafd4";
      header = "#6ec6c6";
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
