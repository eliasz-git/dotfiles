{ ... }:

{
  programs.git = {
    enable = true;
    userName = "tundra-node";
    userEmail = "eliaspublic@icloud.com";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };
}
