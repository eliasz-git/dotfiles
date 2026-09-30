{ config, lib, pkgs, ... }:

# Runtime theme engine.
#
# Nix keeps declaring structure — fonts, sizes, keybindings, layout — and this
# module adds the part that has to change without a rebuild: the colours.
#
# The applier rewrites a small colour fragment per consumer, and the consumer's
# own config sources that fragment. So switching themes is a few file writes plus
# a reload, not a rebuild. This module installs the applier, publishes the
# catalogue it reads, and runs the applier when either the session starts or the
# catalogue changes.
let
  cfg = config.tundra;
  applier = ../../scripts/tundra-theme-apply.sh;
  catalog = {
    sh = config.xdg.configFile."tundra/themes.sh";
    json = config.xdg.configFile."tundra/themes.json";
  };

  # A user unit gets a minimal PATH, and on NixOS the usual locations for these
  # tools do not exist, so the ones the applier shells out to are named here.
  applierPath = lib.makeBinPath [
    pkgs.coreutils
    pkgs.procps
    pkgs.gnused
    pkgs.gawk
  ];
in {
  imports = [ ../../modules/home/themes.nix ];

  home.file.".local/bin/tundra-theme-apply".source = applier;

  # Sourced last, so the fragment's colours override the build-time ones in
  # looknfeel.nix. Those are deliberately left in place: a session can start
  # before the applier has run for the first time, and the declared defaults read
  # better than Hyprland's own during that gap. Hyprland warns about a missing
  # source file and carries on, so the gap degrades rather than breaks.
  wayland.windowManager.hyprland.extraConfig = lib.mkOrder 1000 ''
    source = $HOME/.config/tundra/colors/hyprland.conf
  '';

  systemd.user.services.tundra-theme-apply = lib.mkIf cfg.enable {
    Unit = {
      Description = "Apply the active Tundra theme to the colour fragments";

      # The catalogue is a store symlink, so watching its target is what
      # detects a rebuild that changed the theme registry. This is the same
      # mechanism a PathChanged= line would use, expressed so that Home Manager
      # activation can act on it.
      X-Restart-Triggers = [
        catalog.sh.source
        catalog.json.source
      ];
    };

    Service = {
      Type = "oneshot";
      Environment = "PATH=${applierPath}";
      ExecStart = "%h/.local/bin/tundra-theme-apply";

      # A failed apply leaves a stale theme, not a broken session. Letting the
      # unit exit non-zero would mark it failed and read as worse than it is;
      # the reason is still in the journal.
      SuccessExitStatus = [ "1" ];
    };

    # Applies at session start as well, which is what creates the fragments the
    # moment they are first needed. Re-applying is idempotent, so a session that
    # starts after a switch costs one rewrite.
    Install.WantedBy = [ "default.target" ];
  };
}
