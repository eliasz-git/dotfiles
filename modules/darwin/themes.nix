{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.tundra.enable {
    # macOS screensaver - install aerial via homebrew cask
    homebrew.casks = [ "aerial" ];

    # Lock screen timeout - require password immediately
    # These are the correct nix-darwin options
    system.defaults = {
      screensaver = {
        askForPassword = 1;
        askForPasswordDelay = 0;
      };
    };
  };
}