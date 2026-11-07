{ config, pkgs, lib, ... }:

{
  programs.topgrade = {
    enable = true;
    # Most topgrade settings are commented-out defaults in the standalone
    # topgrade.d/topgrade.toml. Uncomment and adjust as needed.
    # settings = {
    #   misc = {
    #     pre-sudo = false;
    #     assume-yes = null;
    #     no-retry = false;
    #     run-in-tmux = false;
    #   };
    #   brew = {
    #     greedy-cask = false;
    #   };
    # };
  };
}
