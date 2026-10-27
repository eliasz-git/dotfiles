{ config, pkgs, lib, ... }:

{
  programs.thefuck = {
    enable = true;
    settings = {
      # Rules are defined as in the example settings file.
      # Uncomment and change to fit your needs.
      # rules = [ "git_push" "python_command" "sudo" ];
      # exclude_rules = [ ];
      # wait_command = 3;
      # require_confirmation = true;
      # no_colors = false;
      # debug = false;
      # priority = { };
      # history_limit = null;
      # alter_history = true;
      # wait_slow_command = 15;
      # slow_commands = [ "lein" "react-native" "gradle" "./gradlew" "vagrant" ];
      # repeat = false;
      # instant_mode = false;
      # num_close_matches = 3;
      # env = { LC_ALL = "C"; LANG = "C"; GIT_TRACE = "1"; };
      # excluded_search_path_prefixes = [ ];
    };
  };
}
