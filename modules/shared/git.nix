{ ... }:

{
  programs.git = {
    enable = true;
    userName = "{username}";
    userEmail = "{email}";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };
}
