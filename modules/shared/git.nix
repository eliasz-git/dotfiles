{ ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user.name = "tundra-node";
      user.email = "117379918+tundra-node@users.noreply.github.com";
      init.defaultBranch = "main";
      pull.rebase = false;
    };

    # Written to ~/.config/git/ignore. These never belong in a commit, and
    # several repos had them tracked before this existed.
    ignores = [
      ".DS_Store"
      ".AppleDouble"
      ".LSOverride"
      ".idea/"
      "*.swp"
      "*~"
      "__pycache__/"
      "*.pyc"
      ".env"
      ".env.local"
      "*.keystore"
      "local.properties"
    ];
  };
}
