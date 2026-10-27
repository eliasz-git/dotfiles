{ config, pkgs, lib, ... }:

# slskd — headless Soulseek daemon (web UI on :5030).
# Only ONE instance may log in with a Soulseek account at a time, so import this
# on the always-on host and reach it from elsewhere through the web UI.
#
# NO SECRETS LIVE IN THIS REPO. Credentials come from ~/.config/slskd/slskd.env
# (mode 600, not managed by Nix). A template is installed next to it:
#
#   cd ~/.config/slskd && cp slskd.env.example slskd.env && chmod 600 slskd.env && $EDITOR slskd.env
#
# Fail-closed: the service will not start if that file is missing, or if the web
# password is empty / still slskd's built-in default ("slskd"). Before this module,
# the web UI silently ran with the public default login slskd/slskd.
let
  confDir = "${config.home.homeDirectory}/.config/slskd";

  requireWebPassword = pkgs.writeShellScript "slskd-require-web-password" ''
    if [ -z "''${SLSKD_PASSWORD:-}" ] || [ "$SLSKD_PASSWORD" = "slskd" ]; then
      echo "slskd: refusing to start with the default web login." >&2
      echo "       Set SLSKD_PASSWORD (not 'slskd') in ${confDir}/slskd.env" >&2
      exit 1
    fi
  '';
in {
  # Non-secret settings only. Key names follow slskd's own schema (checked against
  # slskd 0.26.0 config/slskd.example.yml): soulseek creds and the web login are
  # supplied by env vars (SLSKD_SLSK_USERNAME / _PASSWORD, SLSKD_USERNAME / _PASSWORD).
  home.file.".config/slskd/slskd.yml".text = ''
    shares:
      directories:
        - "${config.home.homeDirectory}/Music"

    web:
      port: 5030
      https:
        disabled: true
  '';

  home.file.".config/slskd/slskd.env.example".text = ''
    # Copy to slskd.env, chmod 600, fill in. NEVER commit the real file.
    SLSKD_SLSK_USERNAME=your-soulseek-username
    SLSKD_SLSK_PASSWORD=your-soulseek-password
    SLSKD_USERNAME=admin
    SLSKD_PASSWORD=pick-a-long-random-password
  '';

  systemd.user.services.slskd = {
    Unit.Description = "slskd Soulseek daemon (headless, web UI :5030)";
    Service = {
      # No leading "-": a missing env file is an error, not a silent fallback to defaults.
      EnvironmentFile = "${confDir}/slskd.env";
      ExecStartPre = "${requireWebPassword}";
      # slskd only reads ~/.local/share/slskd/slskd.yml by default; point it at ours.
      ExecStart = "${pkgs.slskd}/bin/slskd --config ${confDir}/slskd.yml";
      Restart = "always";
      RestartSec = 10;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
