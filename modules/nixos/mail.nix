{ config, lib, pkgs, ... }:

{
  # Desktop mail clients. Shared by the hosts that want a GUI mail stack.
  #
  # Two clients because they cover different accounts and are not
  # interchangeable:
  #   thunderbird       — iCloud, Gmail, Outlook via IMAP/SMTP (+ CalDAV/CardDAV)
  #   tutanota-desktop  — Tuta only; Tuta deliberately blocks generic IMAP, so
  #                       no other client can read those mailboxes
  #
  # Account credentials are entered on first launch and stored by each client in
  # its own profile (~/.thunderbird, Tuta's config dir). Nothing secret belongs in
  # this repository.
  #
  # No keybinding is defined here: launch from rofi/the app grid. If a shortcut is
  # wanted later, SUPER+M is already taken by rmpc on both Hyprland and Niri.
  home.packages = with pkgs; [
    thunderbird
    tutanota-desktop
  ];

  # `home.packages` only adds binaries to the profile; it does not register
  # launchers, so without these the clients are startable from a terminal but
  # invisible to rofi/drun and the app grid. Both packages ship a .desktop file,
  # but Home Manager only reads its own structured `xdg.desktopEntries`, so the
  # upstream fields are transcribed here. `exec` uses absolute store paths
  # instead of bare names so launching never depends on PATH ordering.
  xdg.desktopEntries.thunderbird = {
    # The attribute key becomes the filename (thunderbird.desktop); `name`
    # becomes the visible Name= label, so it stays capitalised.
    name = "Thunderbird";
    type = "Application";
    exec = "${pkgs.thunderbird}/bin/thunderbird --name thunderbird %U";
    icon = "thunderbird";
    genericName = "Email Client";
    comment = "Read and write e-mails or RSS feeds, or manage tasks on calendars.";
    terminal = false;
    startupNotify = true;
    categories = [
      "Network"
      "Chat"
      "Email"
      "Feed"
      "GTK"
      "News"
    ];
    mimeType = [
      "message/rfc822"
      "x-scheme-handler/mailto"
      "text/calendar"
      "text/x-vcard"
    ];
    settings = {
      Keywords = "mail;email;e-mail;messages;rss;calendar;address book;addressbook;chat";
      StartupWMClass = "thunderbird";
    };
    actions.profile-manager-window = {
      name = "Profile Manager";
      exec = "${pkgs.thunderbird}/bin/thunderbird --ProfileManager";
    };
  };

  xdg.desktopEntries.tutanota-desktop = {
    name = "Tuta";
    type = "Application";
    # Upstream passes --no-sandbox; Tuta's sandbox does not work under the
    # bwrap/FUSE wrapper nixpkgs ships.
    exec = "${pkgs.tutanota-desktop}/bin/tutanota-desktop --no-sandbox %U";
    icon = "tutanota-desktop";
    comment = "The desktop client for Tuta, the secure e-mail, calendar and drive service.";
    terminal = false;
    categories = [
      "Network"
      "Email"
    ];
    mimeType = [ "x-scheme-handler/mailto" ];
    settings.StartupWMClass = "Tuta";
  };
}