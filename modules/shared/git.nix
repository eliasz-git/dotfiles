{ ... }:

{
  programs.git = {
    enable = true;
    userName = "tundra-node";
    userEmail = "117379918+tundra-node@users.noreply.github.com";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };
}
