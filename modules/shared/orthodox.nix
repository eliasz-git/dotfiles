{ config, lib, pkgs, ... }:

let
  # ── Byzantine / Orthodox color palette ─────────────────────────────
  # Imperial Gold, Crimson Red, Deep Royal Blue, Incense Charcoal
  orthodoxPalette = {
    imperialGold = "#D4AF37";
    crimsonRed = "#8B0000";
    deepRoyalBlue = "#002366";
    incenseCharcoal = "#1A1A1A";
    mountAthos = "#2C3E50";
    candleGlow = "#FFE4B5";
    iconBg = "#2D2D2D";
  };

  # ── GOARCH Revised Julian liturgical calendar script ────────────────
  # Primary source: GOARCH online calendar (curl + jq); local fallback
  # uses the Revised Julian paschalion when offline.
  orthodoxLiturgicalScript = pkgs.writeShellScriptBin "orthodox-calendar" ''
    #!/usr/bin/env bash
    set -euo pipefail
    if [ $# -gt 0 ]; then DATE="$1"; else DATE=""; fi
    MODE="full"
    if [ "$#" -ge 1 ]; then
      case "$DATE" in
        --today|--full) MODE="full"; DATE="" ;;
        --fasting) MODE="fasting"; DATE="" ;;
        --feast) MODE="feast"; DATE="" ;;
        --date) MODE="date"; DATE="$2"; shift ;;
        *) MODE="date"; DATE="$1" ;;
      esac
    fi
    [ -z "$DATE" ] && DATE=$(date +%Y-%m-%d)
    if command -v curl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
      if GOARCH_DATA=$(curl -fsS --max-time 8 \
        "https://www.goarch.org/chapel/calendar/feed?date=$DATE" 2>/dev/null); then
        FEAST=$(echo "$GOARCH_DATA" | jq -r '.feast // "Unknown Feast"')
        SAINTS=$(echo "$GOARCH_DATA" | jq -r '.saints // [] | join(", ")')
        FASTING=$(echo "$GOARCH_DATA" | jq -r '.fasting // "Unknown"')
        case "$MODE" in
          full)
            echo "📅 $DATE — $FEAST"
            [ -n "$SAINTS" ] && [ "$SAINTS" != "null" ] && echo "🙏 $SAINTS"
            echo "🍽️  Fasting: $FASTING"
            ;;
          fasting) echo "$FASTING" ;;
          feast) echo "$FEAST" ;;
        esac
        exit 0
      fi
    fi
    python3 - "$DATE" "$MODE" <<'PYEOF'
import sys, datetime

def revised_julian_easter(year):
    a = year % 4
    b = year % 7
    c = year % 19
    d = (19 * c + 15) % 30
    e = (2 * a + 4 * b - d + 34) % 7
    month = (d + e + 114) // 31
    day = ((d + e + 114) % 31) + 1
    return datetime.date(year, month, day)

def orthodox_fasting_status(date):
    year = date.year
    month = date.month
    day = date.day
    dow = date.weekday()
    pascha = revised_julian_easter(year)
    pentecost = pascha + datetime.timedelta(days=49)
    apostles_start = pentecost + datetime.timedelta(days=8)
    dormition_start = datetime.date(year, 8, 1)
    nativity_start = datetime.date(year, 11, 15)
    christmas = datetime.date(year, 12, 25)
    if pascha <= date < pascha + datetime.timedelta(days=40):
        return "Fast Free (Pascha season)"
    if pentecost <= date < apostles_start:
        return "Fast Free (Pentecostarion)"
    if dormition_start <= date <= datetime.date(year, 8, 14):
        return "Dormition Fast (Wine & Oil on weekends)"
    if nativity_start <= date < christmas:
        return "Nativity Fast"
    if apostles_start <= date <= datetime.date(year, 6, 28):
        return "Apostles' Fast"
    if dow in (1, 4):
        return "Strict Fast (Wed/Fri)"
    return "No fasting prescribed"

def orthodox_feast(date):
    feasts = {
        (1, 1): "Circumcision of Christ / St. Basil the Great",
        (1, 6): "Holy Theophany (Epiphany)",
        (2, 2): "Presentation of the Lord",
        (3, 25): "Annunciation of the Theotokos",
        (8, 6): "Transfiguration of the Lord",
        (8, 15): "Dormition of the Theotokos (Parish Feast)",
        (9, 8): "Nativity of the Theotokos",
        (9, 14): "Exaltation of the Holy Cross",
        (11, 21): "Entry of the Theotokos into the Temple",
        (12, 25): "Nativity of Christ (Christmas)",
        (12, 26): "Synaxis of the Theotokos",
    }
    return feasts.get((date.month, date.day), None)

date_str = sys.argv[1]
mode = sys.argv[2] if len(sys.argv) > 2 else "full"
d = datetime.date.fromisoformat(date_str)
feast = orthodox_feast(d)
fasting = orthodox_fasting_status(d)
if mode == "full":
    print(f"📅 {date_str} — Revised Julian (New Calendar)")
    if feast:
        print(f"🎉 {feast}")
    print(f"🍽️  Fasting: {fasting}")
elif mode == "fasting":
    print(fasting)
elif mode == "feast":
    print(feast if feast else "Ordinary day")
PYEOF
'';

  # ── Daily readings script ─────────────────────────────────────────
  orthodoxReadingsScript = pkgs.writeShellScriptBin "orthodox-readings" ''
    #!/usr/bin/env bash
    set -euo pipefail
    DATE="$1"
    [ -z "$DATE" ] && DATE=$(date +%Y-%m-%d)
    if command -v curl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
      if DATA=$(curl -fsS --max-time 8 \
        "https://www.goarch.org/chapel/calendar/feed?date=$DATE" 2>/dev/null); then
        EPISTLE=$(echo "$DATA" | jq -r '.epistle // "Epistle reading unavailable"')
        GOSPEL=$(echo "$DATA" | jq -r '.gospel // "Gospel reading unavailable"')
        echo "═══ DAILY LECTIONARY — $DATE ═══"
        echo ""
        echo "📖 Epistle: $EPISTLE"
        echo ""
        echo "📖 Gospel: $GOSPEL"
        exit 0
      fi
    fi
    echo "═══ DAILY LECTIONARY — $DATE (offline mode) ═══"
    echo ""
    echo "Unable to reach GOARCH online calendar."
    echo "Run 'orthodox-calendar' when network is available."
    exit 1
  '';

  # ── Prayer reminder script ─────────────────────────────────────────
  orthodoxPrayerScript = pkgs.writeShellScriptBin "orthodox-prayer-reminder" ''
    #!/usr/bin/env bash
    set -euo pipefail
    if [ $# -gt 0 ]; then HOUR="$1"; else HOUR="morning"; fi
    case "$HOUR" in
      morning)   TITLE="Orthodox Morning Prayer"; BODY="Time for Orthros / Morning Prayers" ;;
      noon)      TITLE="The Sixth Hour";           BODY="Midday prayers — remember the Cross" ;;
      evening)   TITLE="Orthodox Evening Prayer";  BODY="Time for Vespers / Evening Prayers" ;;
      compline)  TITLE="Compline";                 BODY="Before sleep — Compline prayers" ;;
      vespers)   TITLE="Great Vespers";            BODY="Saturday evening Vespers — prepare for Sunday" ;;
      *)         TITLE="Orthodox Prayer";          BODY="Time to pray" ;;
    esac
    if command -v notify-send >/dev/null 2>&1; then
      notify-send -u normal -i "emblem-symbolic" "$TITLE" "$BODY"
    elif command -v osascript >/dev/null 2>&1; then
      osascript -e "display notification \"$BODY\" with title \"$TITLE\""
    else
      echo "🔔 $TITLE: $BODY"
    fi
  '';

in {
  options.services.orthodox = {
    enable = lib.mkEnableOption "the Orthodox / GOARCH liturgical calendar integration";

    calendar = {
      enable = lib.mkEnableOption "display liturgical day in shell and fastfetch";
      showFasting = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show fasting guidelines in the liturgical banner.";
      };
    };

    theme = {
      enable = lib.mkEnableOption "apply Byzantine Orthodox visual theme";
      wallpaper = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Path to a Byzantine icon wallpaper (e.g., Dormition of the Theotokos).";
      };
      accentColor = lib.mkOption {
        type = lib.types.str;
        default = "#D4AF37";
        description = "Accent color (Imperial Gold by default).";
      };
    };

    notifications = {
      enable = lib.mkEnableOption "systemd user timers for daily prayer reminders";
      morningHour = lib.mkOption {
        type = lib.types.int;
        default = 6;
        description = "Hour (0-23) for morning prayer reminder.";
      };
      eveningHour = lib.mkOption {
        type = lib.types.int;
        default = 18;
        description = "Hour (0-23) for evening prayer reminder.";
      };
      vespersEnable = lib.mkEnableOption "Saturday Great Vespers reminder.";
    };
  };

  config = lib.mkIf config.services.orthodox.enable {
    # ── Packages ──
    home.packages = [
      pkgs.curl
      pkgs.jq
      pkgs.python3
      pkgs.libnotify
    ];

    # ── Shell aliases ──
    programs.zsh.shellAliases = {
      "orthodox-calendar" = "orthodox-calendar";
      "orthodox-readings" = "orthodox-readings";
      "orthodox-prayer" = "orthodox-prayer-reminder";
      "daily-office" = "orthodox-calendar --today && orthodox-readings";
      "liturgy-status" = "orthodox-calendar --fasting";
    };

    # ── fastfetch custom liturgical module ──
    programs.fastfetch = lib.mkIf (config.services.orthodox.calendar.enable or false) {
      settings = {
        modules = lib.optionals (config.services.orthodox.calendar.enable or false) [
          {
            type = "custom";
            format = "📜 LITURGY";
          }
          {
            type = "custom";
            format = "$(orthodox-calendar --today | head -1)";
          }
          {
            type = "custom";
            format = "$(orthodox-calendar --fasting)";
          }
        ];
      };
    };

    # ── Byzantine color theme ──
    home.file.".config/gtk-3.0/settings.ini" = lib.mkIf (config.services.orthodox.theme.enable or false) {
      text = ''
        [Settings]
        gtk-theme-name=Adwaita-dark
        gtk-icon-theme-name=Papirus-Dark
        gtk-font-name=JetBrainsMono Nerd Font 11
        gtk-color-scheme=base_color:#1A1A1A\nfg_color:#D4AF37\nbg_color:#1A1A1A\ntext_color:#D4AF37\nselected_bg_color:#8B0000\nselected_fg_color:#D4AF37
      '';
    };

    # ── Wallpaper reference ──
    home.file.".config/orthodox/wallpaper.txt" = lib.mkIf (config.services.orthodox.theme.wallpaper != null) {
      text = config.services.orthodox.theme.wallpaper;
    };

    # ── systemd user timers for prayer reminders (Linux/NixOS only) ──
    systemd.user = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      services = {
        "orthodox-morning-prayer" = lib.mkIf (config.services.orthodox.notifications.enable or false) {
          description = "Orthodox Morning Prayer reminder";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.libnotify}/bin/notify-send -u normal -i emblem-symbolic \"Orthodox Morning Prayer\" \"Time for Orthros / Morning Prayers\"";
          };
        };
        "orthodox-evening-prayer" = lib.mkIf (config.services.orthodox.notifications.enable or false) {
          description = "Orthodox Evening Prayer reminder";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.libnotify}/bin/notify-send -u normal -i emblem-symbolic \"Orthodox Evening Prayer\" \"Time for Vespers / Evening Prayers\"";
          };
        };
        "orthodox-vespers" = lib.mkIf (config.services.orthodox.notifications.vespersEnable or false) {
          description = "Saturday Great Vespers reminder";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.libnotify}/bin/notify-send -u normal -i emblem-symbolic \"Great Vespers\" \"Saturday evening Vespers — prepare for the Lord's Day\"";
          };
        };
      };
      timers = {
        "orthodox-morning-prayer" = lib.mkIf (config.services.orthodox.notifications.enable or false) {
          description = "Daily Morning Prayer timer";
          timerConfig = {
            OnCalendar = "${builtins.toString (config.services.orthodox.notifications.morningHour or 6)}:00";
            Persistent = true;
          };
          wantedBy = [ "timers.target" ];
        };
        "orthodox-evening-prayer" = lib.mkIf (config.services.orthodox.notifications.enable or false) {
          description = "Daily Evening Prayer timer";
          timerConfig = {
            OnCalendar = "${builtins.toString (config.services.orthodox.notifications.eveningHour or 18)}:00";
            Persistent = true;
          };
          wantedBy = [ "timers.target" ];
        };
        "orthodox-vespers" = lib.mkIf (config.services.orthodox.notifications.vespersEnable or false) {
          description = "Weekly Saturday Great Vespers";
          timerConfig = {
            OnCalendar = "Sat *:18:00";
            Persistent = true;
          };
          wantedBy = [ "timers.target" ];
        };
      };
    };
  };
}
