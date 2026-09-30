{ config, lib, pkgs, ... }:

# Desktop entries for tools that ship no .desktop file of their own.
#
# Most of these are TUIs that the desktop already exposes through Hyprland
# keybindings (see modules/nixos/hyprland/bindings.nix), but a keybinding only
# helps someone who already remembers it. Advertising them in the launcher makes
# them discoverable and keeps the icon list honest.
#
# Terminal tools launch inside foot, which is the terminal bound to
# `SUPER, Return` and used by every `foot -e ...` binding. GUI tools run
# directly. The Exec paths are resolved through the nix store rather than
# relying on PATH so an entry cannot silently break if a binary moves.

let
  foot = lib.getExe pkgs.foot;

  entries = [
    {
      id = "opencode";
      name = "opencode";
      genericName = "AI Coding Agent";
      comment = "Terminal AI coding agent";
      exec = "${foot} -e opencode";
      icon = "utilities-terminal";
      keywords = "ai;agent;llm;code;";
    }
    {
      id = "lazygit";
      name = "lazygit";
      genericName = "Git Client";
      comment = "Terminal UI for git";
      exec = "${foot} -e lazygit";
      icon = "git";
      keywords = "git;vcs;repository;";
    }
    {
      id = "atuin";
      name = "atuin";
      genericName = "Shell History";
      comment = "Search your shell history";
      exec = "${foot} -e atuin";
      icon = "utilities-terminal";
      keywords = "shell;history;search;recall;";
    }
    {
      id = "wlogout";
      name = "wlogout";
      genericName = "Session";
      comment = "Log out, reboot or power off";
      exec = lib.getExe pkgs.wlogout;
      icon = "system-shutdown";
      keywords = "logout;reboot;poweroff;suspend;session;";
    }
    {
      id = "tundra-record";
      name = "Record Screen";
      genericName = "Screen Recorder";
      comment = "Record the screen to ~/Videos";
      exec = "${foot} -e tundra-record";
      icon = "record-desktop";
      keywords = "record;screen;capture;video;";
    }
  ];

  toDesktopEntry =
    e: ''
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=${e.name}
      GenericName=${e.genericName}
      Comment=${e.comment}
      Exec=${e.exec}
      TryExec=${lib.head (lib.splitString " " e.exec)}
      Icon=${e.icon}
      Terminal=false
      Categories=Development;Utility;
      Keywords=${e.keywords}
      StartupNotify=true
    '';
  desktopEntries = lib.listToAttrs (
    map (e: {
      name = ".local/share/applications/${e.id}.desktop";
      value = { text = toDesktopEntry e; };
    })
    entries
  );

  # tundra-record is a wrapper because wf-recorder has no GUI and needs flags
  # to be useful; see scripts/tundra-record.sh.
  scripts = {
    ".local/bin/tundra-record".source = ../../scripts/tundra-record.sh;
  };
in
{
  config = lib.mkIf config.tundra.enable {
    home.file = desktopEntries // scripts;
  };
}
