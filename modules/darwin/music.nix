{ config, lib, pkgs, ... }:

let
  cfg = config.programs.apple-music-scrobbler;
  # Upstream ships its own `install` subcommand that writes an unmanaged plist.
  # We declare the agent instead so it lands in the repo; the label and the
  # `run` subcommand are upstream's, so `apple-to-last-fm uninstall` still works.
  label = "com.apple-to-last-fm";
  logDir = "${config.home.homeDirectory}/Library/Logs/apple-to-last-fm";
in
{
  options.programs.apple-music-scrobbler = {
    enable = lib.mkEnableOption "the apple-to-last-fm daemon";

    package = lib.mkPackageOption pkgs "apple-to-last-fm" { };
  };

  config = lib.mkIf cfg.enable {
    programs.apple-music-scrobbler.package =
      let
        src = pkgs.fetchFromGitHub {
          owner = "jeremywrnr";
          repo = "apple-to-last-fm";
          rev = "v1.2.1";
          hash = "sha256:0in8rap1sphn0c3xiimr5asi9hp4k12xy903iwg286ap6na4g0jf";
        };
      in
      pkgs.rustPlatform.buildRustPackage {
        pname = "apple-to-last-fm";
        version = "1.2.1";
        inherit src;
        # Upstream commits Cargo.lock, so the vendor hash is reproducible without
        # vendoring into this repo.
        cargoLock.lockFile = "${src}/Cargo.lock";
        doCheck = false;
        meta = {
          description = "Scrobble Apple Music plays to Last.fm";
          license = pkgs.lib.licenses.mit;
          platforms = pkgs.lib.platforms.darwin;
        };
      };

    home.packages = [ cfg.package ];

    # The daemon polls Music.app and posts to Last.fm. Credentials come from
    # `apple-to-last-fm auth`, which does a browser login and stores a session
    # key in ~/Library/Application Support/apple-to-last-fm/config.toml, so no
    # password is managed by Nix.
    launchd.agents.${label} = {
      config = {
        # Home Manager would otherwise label this org.nix-community.home.*, which
        # breaks `apple-to-last-fm uninstall` and `logs`, both of which look up
        # the upstream label.
        Label = label;
        ProgramArguments = [ "${cfg.package}/bin/apple-to-last-fm" "run" ];
        RunAtLoad = true;
        KeepAlive = true;
        ProcessType = "Background";
        StandardOutPath = "${logDir}/output.log";
        StandardErrorPath = "${logDir}/error.log";
      };
    };

    # launchd will not create the log directory, and Home Manager cannot
    # express an empty one, so make it before the agent is loaded.
    home.activation.appleMusicScrobblerLogDir =
      lib.hm.dag.entryBefore [ "setupLaunchAgents" ] ''
        mkdir -p "$HOME/Library/Logs/apple-to-last-fm"
      '';
  };
}
