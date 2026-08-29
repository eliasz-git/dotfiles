{ pkgs, ... }:
{
  home.file.".local/bin/app-launcher" = {
    executable = true;
    text = ''
      #!/bin/sh
      # app-launcher — rofi for macOS, fzf with favorites + categories + descriptions
      set -e
      FAV_FILE="$HOME/.config/tui-launcher/favorites"
      FAV_DEFAULT="$HOME/.config/tui-launcher/favorites.default"
      mkdir -p "$(dirname "$FAV_FILE")"
      if [ ! -f "$FAV_FILE" ]; then
        if [ -f "$FAV_DEFAULT" ]; then cp "$FAV_DEFAULT" "$FAV_FILE"; else cat > "$FAV_FILE" << 'FAV'
      Ghostty
      yazi
      btop
      cmus
      newsboat
      glow
      helix
      mpv
      lazydocker
      Firefox
      Obsidian
      FAV
        fi
      fi

      desc() {
        case "$1" in
          yazi) echo "blazing fast file manager (ranger replacement)" ;;
          lf) echo "terminal file manager, fast" ;;
          nnn) echo "tiny file manager" ;;
          cmus) echo "console music player — local library (foobar2000)" ;;
          mpd) echo "music daemon — server for ncmpcpp/rmpc" ;;
          ncmpcpp) echo "MPD client — ncurses (local music)" ;;
          termusic) echo "Rust music player — local + streaming" ;;
          rmpc) echo "Rust MPD client" ;;
          musikcube) echo "terminal music player + streaming" ;;
          beets) echo "music tagger — XLD replacement" ;;
          neomutt) echo "TUI email — Tuta/Gmail via himalaya" ;;
          aerc) echo "email client — aerc" ;;
          himalaya) echo "email CLI — Tuta/Himalaya" ;;
          weechat) echo "IRC/chat — Beeper bridge" ;;
          discordo) echo "Discord TUI" ;;
          gurk-rs) echo "Signal TUI" ;;
          newsboat) echo "RSS reader — NetNewsWire replacement" ;;
          glow) echo "markdown renderer — Obsidian preview" ;;
          zk) echo "zettelkasten notes" ;;
          nb) echo "notes + bookmarks" ;;
          mdcat) echo "markdown cat" ;;
          w3m) echo "terminal browser — Firefox light" ;;
          lynx) echo "text browser" ;;
          elinks) echo "text browser with JS" ;;
          browsh) echo "Firefox in terminal — full JS" ;;
          helix) echo "post-modern editor — VSCodium replacement" ;;
          micro) echo "micro editor" ;;
          nano) echo "nano — your editor" ;;
          mpv) echo "media player — IINA replacement" ;;
          yt-dlp) echo "YouTube downloader" ;;
          ytfzf) echo "fuzzy YouTube → mpv (GrayJay)" ;;
          btop) echo "system monitor — beautiful" ;;
          bottom) echo "system monitor — bottom (btm)" ;;
          htop) echo "process viewer" ;;
          duf) echo "disk usage — pretty df" ;;
          dust) echo "disk usage — du" ;;
          ncdu) echo "disk usage — ncurses" ;;
          lazydocker) echo "Docker TUI — Docker Desktop replacement" ;;
          lazygit) echo "git TUI" ;;
          cmatrix) echo "matrix fun" ;;
          cbonsai) echo "bonsai fun" ;;
          pipes) echo "pipes fun" ;;
          Firefox) echo "web browser — GUI" ;;
          BrowserOS) echo "browser — BrowserOS" ;;
          VSCodium) echo "code editor — GUI" ;;
          Zed) echo "code editor — GUI" ;;
          IINA) echo "media player — GUI" ;;
          foobar2000) echo "music player — GUI local" ;;
          Beeper) echo "chat — GUI" ;;
          Discord) echo "chat — GUI" ;;
          Obsidian) echo "notes — GUI" ;;
          Ghostty) echo "terminal — your main" ;;
          Termius) echo "SSH client — GUI" ;;
          KeepassXC) echo "password manager — GUI" ;;
          "Yubico Authenticator") echo "Yubikey — GUI" ;;
          Lulu) echo "firewall — LuLu" ;;
          Tailscale) echo "VPN — Tailscale" ;;
          "Cloudflare WARP") echo "VPN — WARP" ;;
          *) echo "app — $1" ;;
        esac
      }

      add_cat() {
        while read -r a; do
          [ -z "$a" ] && continue
          d="$(desc "$a")"
          printf "%s\t%s\t%s\n" "$1" "$a" "$d"
        done
      }

      FAVS="$(cat "$FAV_FILE" 2>/dev/null | grep -v "^#" | grep -v "^$" | head -n 20)"
      TUI_FILES="$(printf "yazi\nlf\nnnn\n" )"
      TUI_MUSIC="$(printf "cmus\nmpd\nncmpcpp\ntermusic\nrmpc\nmusikcube\n" )"
      TUI_MAIL="$(printf "neomutt\naerc\nhimalaya\n" )"
      TUI_CHAT="$(printf "weechat\ndiscordo\ngurk-rs\n" )"
      TUI_RSS="$(printf "newsboat\n" )"
      TUI_NOTES="$(printf "glow\nzk\nnb\nmdcat\n" )"
      TUI_BROWSER="$(printf "w3m\nlynx\nelinks\nbrowsh\n" )"
      TUI_EDITOR="$(printf "helix\nmicro\nnano\n" )"
      TUI_MEDIA="$(printf "mpv\nyt-dlp\nytfzf\n" )"
      TUI_SYS="$(printf "btop\nbottom\nhtop\nduf\ndust\nncdu\nlazydocker\nlazygit\n" )"
      TUI_FUN="$(printf "cmatrix\ncbonsai\npipes\n" )"
      GUI_BROWSER="$(printf "Firefox\nBrowserOS\n" )"
      GUI_CODE="$(printf "VSCodium\nZed\n" )"
      GUI_MEDIA="$(printf "IINA\nfoobar2000\n" )"
      GUI_CHAT="$(printf "Beeper\nDiscord\n" )"
      GUI_NOTES="$(printf "Obsidian\n" )"
      GUI_SYS="$(printf "Ghostty\nTermius\nKeepassXC\nYubico Authenticator\nLulu\nTailscale\nCloudflare WARP\n" )"

      INPUT=""
      INPUT="$INPUT$(echo "$FAVS" | add_cat "★ Favorites")\n"
      INPUT="$INPUT$(echo "$TUI_FILES" | add_cat "📁 Files")\n"
      INPUT="$INPUT$(echo "$TUI_MUSIC" | add_cat "🎵 Music")\n"
      INPUT="$INPUT$(echo "$TUI_MAIL" | add_cat "✉ Mail")\n"
      INPUT="$INPUT$(echo "$TUI_CHAT" | add_cat "💬 Chat")\n"
      INPUT="$INPUT$(echo "$TUI_RSS" | add_cat "📰 RSS")\n"
      INPUT="$INPUT$(echo "$TUI_NOTES" | add_cat "📝 Notes")\n"
      INPUT="$INPUT$(echo "$TUI_BROWSER" | add_cat "🌐 Browser")\n"
      INPUT="$INPUT$(echo "$TUI_EDITOR" | add_cat "✏ Editor")\n"
      INPUT="$INPUT$(echo "$TUI_MEDIA" | add_cat "🎬 Media")\n"
      INPUT="$INPUT$(echo "$TUI_SYS" | add_cat "⚙ System")\n"
      INPUT="$INPUT$(echo "$TUI_FUN" | add_cat "🎮 Fun")\n"
      INPUT="$INPUT$(echo "$GUI_BROWSER" | add_cat "🌐 GUI-Browser")\n"
      INPUT="$INPUT$(echo "$GUI_CODE" | add_cat "💻 GUI-Code")\n"
      INPUT="$INPUT$(echo "$GUI_MEDIA" | add_cat "🎬 GUI-Media")\n"
      INPUT="$INPUT$(echo "$GUI_CHAT" | add_cat "💬 GUI-Chat")\n"
      INPUT="$INPUT$(echo "$GUI_NOTES" | add_cat "📝 GUI-Notes")\n"
      INPUT="$INPUT$(echo "$GUI_SYS" | add_cat "⚙ GUI-System")\n"
      ALL_GUI="$(ls /Applications/*.app 2>/dev/null | xargs -I{} basename {} .app | sort -u)"
      INPUT="$INPUT$(echo "$ALL_GUI" | add_cat "GUI-All")\n"

      # Dedupe on app name (col 2), keep favorites first, show category + app + description
      CHOICE_RAW="$(printf "%b" "$INPUT" | grep -v "^\s*$" | awk -F'\t' '!seen[$2]++' | fzf --with-nth=1,2,3 --delimiter="\t" --prompt="launch> " --height=75% --reverse --border=rounded --color=bg:#04182F,fg:#68A2C6,hl:#116FAE,fg+:#68A2C6,bg+:#06467E,hl+:#116FAE,info:#7E8A94,marker:#305561,prompt:#116FAE,spinner:#68A2C6,pointer:#116FAE,header:#305561 --header="★ Favorites — Files/Music/Mail/Chat/RSS/Notes/Browser/Editor/Media/System/Fun + GUI — descriptions shown" --preview="echo {1} {2} — {3}" --preview-window=up:1 --accept-nth=2)"

      [ -z "$CHOICE_RAW" ] && exit 0
      CHOICE="$(echo "$CHOICE_RAW" | awk -F'\t' '{print $2}')"
      [ -z "$CHOICE" ] && CHOICE="$(echo "$CHOICE_RAW" | awk '{print $NF}')"
      if command -v "$CHOICE" >/dev/null 2>&1; then exec "$CHOICE"; else if open -a "$CHOICE" 2>/dev/null; then exit 0; fi; APP_PATH="$(mdfind "kMDItemDisplayName == '$CHOICE' && kMDItemKind == 'Application'" 2>/dev/null | head -n1)"; [ -n "$APP_PATH" ] && open "$APP_PATH" || open -a "$CHOICE"; fi
    '';
  };
  home.file.".local/bin/tui-launcher" = {
    executable = true;
    text = ''
      #!/bin/sh
      exec "$HOME/.local/bin/app-launcher" "$@"
    '';
  };
  home.file.".config/tui-launcher/favorites.default".text = ''
    Ghostty
    yazi
    btop
    cmus
    newsboat
    glow
    helix
    mpv
    lazydocker
    Firefox
    Obsidian
  '';
}
