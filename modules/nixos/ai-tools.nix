{ config, lib, pkgs, ... }:

{
  # AI Development Tools
  home.packages = with pkgs; [
    # OpenCode - AI coding agent
    (pkgs.nodePackages.opencode or pkgs.opencode)

    # Claude Code - Anthropic's CLI
    (pkgs.nodePackages.claude-code or pkgs.claude-code)

    # Gemini CLI - Google's CLI
    (pkgs.nodePackages.gemini-cli or pkgs.gemini-cli)

    # Copilot CLI - GitHub Copilot
    (pkgs.nodePackages.copilot-cli or pkgs.copilot-cli)

    # Additional AI tools
    pkgs.ollama
    pkgs.llama-cpp
  ];

  # Ollama service for local LLMs
  services.ollama = {
    enable = true;
    openFirewall = false;
  };

  # Environment variables for AI tools
  environment.sessionVariables = {
    # Ollama
    OLLAMA_HOST = "127.0.0.1:11434";

    # API keys (set via ~/.config/ai-keys.sh or direnv)
    # ANTHROPIC_API_KEY = ""
    # OPENAI_API_KEY = ""
    # GEMINI_API_KEY = ""
    # GITHUB_COPILOT_TOKEN = ""
  };

  # User service for loading AI API keys from secure file
  systemd.user.services.ai-keys = {
    description = "Load AI API keys from secure file";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStartPre = "${pkgs.writeShellScript \"ai-keys-setup\" ''\n        mkdir -p $HOME/.config\n        if [ ! -f $HOME/.config/ai-keys.sh ]; then\n          cat > $HOME/.config/ai-keys.sh <<'EOF'\n# AI API Keys - source this file or add to shell init\n# export ANTHROPIC_API_KEY=\"\"\n# export OPENAI_API_KEY=\"\"\n# export GEMINI_API_KEY=\"\"\n# export GITHUB_COPILOT_TOKEN=\"\"\nEOF\n          chmod 600 $HOME/.config/ai-keys.sh\n        fi\n      ''}";
      ExecStart = "true";
    };
  };

  # Shell integration for AI keys
  programs.zsh.initContent = lib.mkOrder 600 ''
    [ -f "$HOME/.config/ai-keys.sh" ] && source "$HOME/.config/ai-keys.sh"
  '';
}