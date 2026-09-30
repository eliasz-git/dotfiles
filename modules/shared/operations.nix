{ pkgs, ... }:

{
  # Keep the operational entry point identical on every Home Manager host.
  home.packages = [
    pkgs.gh
    (pkgs.writeScriptBin "tundra" (builtins.readFile ../../scripts/tundra-cli.sh))
  ];

  programs.zsh.shellAliases = {
    # Nix lifecycle: rb activates, rbu updates inputs and builds without activation.
    rb = "tundra switch";
    rbu = "tundra update";
    rbb = "tundra build";
    rbe = "tundra eval";
    rbt = "tundra test";
    rbbt = "tundra boot";
    rbr = "tundra rollback";
    wp = "tundra wallpaper list";
    wps = "tundra wallpaper set";

    # GitHub CLI / Actions shortcuts. These are read-only unless gh itself is
    # explicitly used for a mutating command.
    ghs = "gh run list --limit 10";
    ghw = "gh run watch";
    ghpr = "gh pr view --web";
    ghci = "gh workflow list";
    ghl = "gh auth login";
  };
}
