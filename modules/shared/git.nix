{ ... }:

{
  programs.git = {
    enable = true;
    userName = "{username}";
    userEmail = "117379918+{username}@users.noreply.github.com";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };
}
