{ config, lib, pkgs, ... }:

let
  cfg = config.services.homelabCompose;

  stackModule = { name, ... }: {
    options = {
      enable = lib.mkEnableOption "the ${name} homelab Compose stack";
      composeFile = lib.mkOption {
        type = lib.types.path;
        description = "Tracked Compose file for this stack.";
      };
      requiredMounts = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Mount points that must exist before the stack starts.";
      };
      environmentFile = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Optional external Compose env file, never stored in the repository.";
      };
    };
  };

  enabledStacks = lib.filterAttrs (_: stack: stack.enable) cfg.stacks;

  mkStack = name: stack:
    let
      composeFile = "/etc/stacks/${name}/compose.yaml";
      envArg = lib.optionalString (stack.environmentFile != null)
        "--env-file ${stack.environmentFile}";
      mountChecks = map
        (mount: "${pkgs.util-linux}/bin/mountpoint --quiet ${lib.escapeShellArg mount}")
        stack.requiredMounts;
      secretCheck = lib.optional (stack.environmentFile != null)
        "${pkgs.coreutils}/bin/test -r ${lib.escapeShellArg stack.environmentFile}";
    in {
      environment.etc."stacks/${name}/compose.yaml".source = stack.composeFile;

      systemd.services."homelab-compose-${name}" = {
        description = "Homelab Compose stack: ${name}";
        after = [ "docker.service" "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStartPre = mountChecks ++ secretCheck;
          ExecStart = "${pkgs.docker-compose}/bin/docker-compose ${envArg} -f ${composeFile} config";
          ExecStartPost = "${pkgs.docker-compose}/bin/docker-compose ${envArg} -f ${composeFile} up -d";
          ExecStop = "${pkgs.docker-compose}/bin/docker-compose ${envArg} -f ${composeFile} down";
          TimeoutStartSec = "15min";
          TimeoutStopSec = "5min";
        };
      };
    };
in
{
  options.services.homelabCompose.stacks = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule stackModule);
    default = { };
    description = "Docker Compose stacks managed by systemd and NixOS.";
  };

  config = lib.mkMerge (lib.mapAttrsToList mkStack enabledStacks);
}
