{ config, lib, pkgs, ... }:

{
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
      gemini = "gemini-cli";
      # copilot = "copilot-cli";  # Not in nixpkgs - install via npm: npm i -g @github/copilot-cli
    };
    sessionVariables = {
      NPM_CONFIG_PREFIX = "$HOME/.npm-global";
      BAT_THEME = "base16";
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
    # Disable fzf's Ctrl-R binding since atuin owns it
    historyWidget.zsh.command = "";
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
