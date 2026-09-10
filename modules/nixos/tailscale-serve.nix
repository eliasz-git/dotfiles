{ config, lib, ... }:

with lib;

let
  cfg = config.services.tailscaleServe;

  ts = "${config.services.tailscale.package}/bin/tailscale";

  mkServeCmd = name: svc:
    "${ts} serve --service svc:${name} --https 443 --bg ${toString svc.port}";
  mkOffCmd = name:
    "${ts} serve --service svc:${name} --https 443 off || true";

in {
  options.services.tailscaleServe = {
    services = mkOption {
      default = { };
      description = ''
        Tailscale `serve --service svc:NAME --https 443 --bg PORT` mappings,
        applied sequentially by a single systemd service on start.

        Registering these as separate systemd units (one per svc:) causes
        an etag race whenever tailscaled restarts — they all fire at once
        and fight over the shared serve config, so several fail with
        "Another client is changing the serve config; please try again".
        This module runs every `tailscale serve` call one after another
        in a single unit instead, so there's nothing to race.
      '';
      type = types.attrsOf (types.submodule {
        options = {
          port = mkOption {
            type = types.port;
            description = "Local port the svc: should proxy to.";
          };
          description = mkOption {
            type = types.str;
            default = "";
            description = "Optional human-readable note for this svc:.";
          };
        };
      });
      example = {
        media = { port = 8096; description = "Jellyfin"; };
      };
    };
  };

  config = mkIf (cfg.services != { }) {
    systemd.services.tailscale-serve = {
      description = "Tailscale serve — all svc: mappings (applied sequentially)";
      after = [ "tailscaled.service" "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = 5;
      };
      script = concatStringsSep "\n"
        (mapAttrsToList mkServeCmd cfg.services);
      preStop = concatStringsSep "\n"
        (map mkOffCmd (attrNames cfg.services));
    };
  };
}
