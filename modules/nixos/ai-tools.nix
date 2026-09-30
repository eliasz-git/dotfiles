{ config, lib, pkgs, ... }:

{
  # AI Development Tools (Home Manager user-level)

  # AI packages
  home.packages = with pkgs; [
    opencode      # AI coding agent
    antigravity-cli
    llama-cpp
    # ollama isn't listed here: services.ollama.enable below already
    # installs the ollama package as part of the service.
  ];

  # Ollama service for local LLMs. Home-Manager's services.ollama has no
  # openFirewall knob (that's NixOS-only) — it's moot anyway, since the
  # default host (127.0.0.1) never touches the firewall.
  services.ollama.enable = true;

  # Environment variables for AI tools (home-manager level, since module included via Home Manager)
  home.sessionVariables = {
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
    Unit.Description = "Load AI API keys from secure file";
    Install.WantedBy = [ "default.target" ];
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStartPre = "${pkgs.writeShellScript "ai-keys-setup" ''
        mkdir -p $HOME/.config
        if [ ! -f $HOME/.config/ai-keys.sh ]; then
          cat > $HOME/.config/ai-keys.sh <<'EOF'
# AI API Keys - source this file or add to shell init
# export ANTHROPIC_API_KEY=""
# export OPENAI_API_KEY=""
# export GEMINI_API_KEY=""
# export GITHUB_COPILOT_TOKEN=""
EOF
          chmod 600 $HOME/.config/ai-keys.sh
        fi
      ''}";
      ExecStart = "true";
    };
  };

  # Shell integration for AI keys
  programs.zsh.initContent = lib.mkOrder 600 ''
    [ -f "$HOME/.config/ai-keys.sh" ] && source "$HOME/.config/ai-keys.sh"
  '';
}
