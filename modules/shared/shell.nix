{ config, lib, pkgs, ... }:

let
  palette = config.tundra.palette or {
    base = "#2d353b"; mantle = "#272e33"; surface1 = "#3d484d";
    text = "#d3c6aa"; subtext0 = "#a7a89c"; subtext1 = "#b0b79c";
    blue = "#7fbbb3"; mauve = "#d699b6"; pink = "#d699b6";
    yellow = "#dbbc7f"; green = "#a7c080"; red = "#e67e80"; teal = "#83c092";
  };
in {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    dotDir = lib.mkDefault (config.xdg.configHome + "/zsh");
    shellAliases = {
      # Core
      ls = "eza --icons";
      ll = "eza -la --icons";
      lt = "eza --tree --icons";
      cat = "bat --paging=never";
      cd = "z";
      # Git
      g = "git";
      gs = "git status";
      gd = "git diff";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";
      gco = "git checkout";
      gb = "git branch";
      # Utils
      sc = "sconnect";
      v = "nvim";
      vi = "nvim";
      # Theme
      theme = "tundra-theme";
      themes = "tundra-theme list";
      # AI
      ai = "opencode";
      # claude = "claude-code";  # Not in nixpkgs - install via npm: npm i -g @anthropic-ai/claude-code
      antigravity = "agy";
      gemini = "agy";
      # copilot = "copilot-cli";  # Not in nixpkgs - install via npm: npm i -g @github/copilot-cli
    };
    sessionVariables = {
      NPM_CONFIG_PREFIX = "$HOME/.npm-global";
      BAT_THEME = "ansi";
      FZF_DEFAULT_OPTS = "--height 40% --layout=reverse --border";
    };
    initContent = lib.mkOrder 550 ''
      eval "$(zoxide init zsh)"
      # eval "$(pay-respects zsh --alias)"  # Not in nixpkgs
      eval "$(atuin init zsh)"
      export PATH="$HOME/.npm-global/bin:$PATH"
      export PATH="$HOME/.local/bin:$PATH"
      if command -v terminal-wakatime >/dev/null 2>&1; then
        export PATH="$HOME/.wakatime:$PATH"
        eval "$(terminal-wakatime init)"
      fi
      FPATH="$HOME/.docker/completions:$FPATH"
      autoload -Uz compinit
      compinit
    '';
  };
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    # sync is not a valid option; daemon handles sync
  };
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      format = "$username$hostname$directory$git_branch$git_status$nix_shell$character";
      character = {
        error_symbol = "[➜](bold ${palette.red})";
        success_symbol = "[➜](bold ${palette.blue})";
      };
      directory = {
        style = "bold ${palette.blue}";
        truncate_to_repo = true;
        truncation_length = 3;
      };
      git_branch = {
        style = "bold ${palette.mauve}";
        symbol = " ";
      };
      git_status = {
        style = "bold ${palette.subtext0}";
      };
      nix_shell = {
        format = "via [$symbol$state]($style) ";
        style = "bold ${palette.teal}";
        symbol = " ";
      };
    };
  };
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    # Disable fzf's Ctrl-R binding since atuin owns it
    historyWidget.zsh.command = "";
    colors = {
      bg = palette.base;
      "bg+" = palette.mantle;
      fg = palette.text;
      "fg+" = palette.subtext1;
      hl = palette.red;
      "hl+" = palette.red;
      info = palette.blue;
      marker = palette.green;
      prompt = palette.blue;
      spinner = palette.pink;
      pointer = palette.pink;
      header = palette.teal;
    };
  };
  programs.bat = {
    enable = true;
    config = {
      theme = "ansi";
      pager = "less -FR";
    };
  };
}
