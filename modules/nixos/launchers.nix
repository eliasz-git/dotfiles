{ config, lib, pkgs, ... }:

# Desktop entries for tools that ship no .desktop file of their own.
#
# Most of these are TUIs that the desktop already exposes through Mango
# keybindings (see modules/nixos/mango/bindings.nix), but a keybinding only
# helps someone who already remembers it. Advertising them in the launcher makes
# them discoverable and keeps the icon list honest.
#
# Terminal tools launch inside foot, which is the terminal bound to
# `SUPER, Return` and used by every `foot -e ...` binding. GUI tools run
# directly. The Exec paths are resolved through the nix store rather than
# relying on PATH so an entry cannot silently break if a binary moves.
#
# The webEntries list below is the same idea for services that ship no Linux
# client at all: Adobe publishes no Linux builds of Photoshop, Lightroom or
# Bridge, and Google ships no Linux Drive client, so those entries open the
# web versions instead. Bridge has no web app of its own, so its entry opens
# the Creative Cloud web hub where synced assets and libraries live.

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
      id = "anki";
      name = "Anki";
      genericName = "Flashcards";
      comment = "Spaced repetition flashcards";
      exec = lib.getExe pkgs.anki-bin;
      # The upstream .desktop file asks for the icon theme name "anki", which
      # Papirus does not ship. The package keeps the real one here, so point
      # the entry at the file directly.
      icon = "${pkgs.anki-bin}/share/pixmaps/anki.png";
      keywords = "anki;flashcards;spaced repetition;study;fsrs;";
      categories = "Education;Languages";
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

  # Web apps for services with no Linux client. Adobe publishes no Linux
  # builds of the Creative Cloud desktop apps and Google ships no Linux
  # Drive client, so these open the web versions in Zen Browser (by binary
  # name, like the SUPER,b Mango binding, because the zen-browser flake
  # input is only in scope in the host home.nix files). No TryExec: it would
  # point at a PATH binary rather than a store path, and the missing-binary
  # check would hide the entry from launchers that honour TryExec.
  webEntries = [
    {
      id = "adobe-photoshop";
      name = "Photoshop";
      genericName = "Image Editor";
      comment = "Adobe Photoshop on the web";
      exec = "zen-beta https://photoshop.adobe.com";
      icon = "AdobePhotoshop";
      categories = "Graphics;";
      keywords = "adobe;photoshop;creative;cloud;image;photo;editor;";
    }
    {
      id = "adobe-lightroom";
      name = "Lightroom";
      genericName = "Photo Editor";
      comment = "Adobe Lightroom on the web";
      exec = "zen-beta https://lightroom.adobe.com";
      icon = "AdobeLightroom";
      categories = "Graphics;";
      keywords = "adobe;lightroom;creative;cloud;photo;raw;organize;";
    }
    {
      id = "adobe-bridge";
      name = "Adobe Bridge";
      genericName = "Creative Cloud Hub";
      comment = "Bridge has no web app; opens the Creative Cloud hub for synced assets and libraries";
      exec = "zen-beta https://creativecloud.adobe.com";
      icon = "AdobeBridge";
      categories = "Graphics;FileManager;";
      keywords = "adobe;bridge;creative;cloud;assets;libraries;files;";
    }
    {
      id = "google-drive";
      name = "Google Drive";
      genericName = "Cloud Storage";
      comment = "Google Drive on the web";
      exec = "zen-beta https://drive.google.com";
      icon = "google-drive";
      categories = "Network;Office;";
      keywords = "google;drive;cloud;storage;docs;files;";
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
      Categories=${e.categories or "Development;Utility;"};
      Keywords=${e.keywords}
      StartupNotify=true
    '';
  toWebEntry =
    e: ''
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=${e.name}
      GenericName=${e.genericName}
      Comment=${e.comment}
      Exec=${e.exec}
      Icon=${e.icon}
      Terminal=false
      Categories=${e.categories}
      Keywords=${e.keywords}
      StartupNotify=true
    '';

  desktopEntries = lib.listToAttrs (
    (map (e: {
      name = ".local/share/applications/${e.id}.desktop";
      value = { text = toDesktopEntry e; };
    }) entries)
    ++ (map (e: {
      name = ".local/share/applications/${e.id}.desktop";
      value = { text = toWebEntry e; };
    }) webEntries)
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
