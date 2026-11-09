{ config, lib, pkgs, ... }:

# ── Eastern Orthodox ────────────────────────────────────────────────────
# Bible study tools (Sword Project) for Orthodox study. Inside Xiphos /
# BibleTime, use the download manager to add public-domain modules such as
# Brenton's Septuagint (LXX — the Greek OT used by the Orthodox Church).
#
# Parish shortcuts:
#   dormition          parish home page (dormitionpgh.org)
#   dormition calendar parish calendar
#   dormition clergy   Fr. Michael Gavrilos & clergy
#   dormition festival Greek Food Festival / Gyro Fest
#   dormition live     live-streamed services (YouTube)
#   dormition veil     monthly newsletter "The Veil"
#   dormition metropolis Metropolis of Pittsburgh website
#   dormition goarch   Greek Orthodox Archdiocese of America
#   dormition chapel   GOARCH Online Chapel (daily readings, saints, feasts)
#
# Scripts deployed to ~/.local/bin via home.file in hosts/desktop/home.nix.
# orthodox-readings opens today's readings at your parish by default.

{
  home.sessionVariables = {
    ORTHODOX_READINGS_URL = "https://dormitionpgh.org/";
  };

  home.packages = with pkgs; [
    xiphos   # GTK Bible study (Sword Project)
    bibletime  # KDE Bible study (Sword Project)
  ];
}
