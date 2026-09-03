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
  };
}
