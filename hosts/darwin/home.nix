{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/shared/programs.nix
    ../../modules/shared/shell.nix
    ../../modules/shared/git.nix
    ../../modules/shared/multiplexer.nix
    ../../modules/shared/fastfetch.nix
    ../../modules/shared/operations.nix
    ../../modules/home/themes.nix
    ../../modules/darwin/terminal.nix
    ../../modules/darwin/sketchybar.nix
    ../../modules/darwin/syncthing.nix
  ];

  home.stateVersion = "26.05";
  programs.home-manager.enable = true;
  manual.manpages.enable = false;

  # Enable theme system
  tundra.enable = true;
  tundra.theme = "everforest-blue";

  # Karabiner — keeps keyboard remaps under version control
  # Caps Lock → Left Command (feels like SUPER)
  home.file.".config/karabiner".source =
    config.lib.file.mkOutOfStoreSymlink
      "/Users/elias/.config/nix-config/modules/darwin/karabiner";

  # AeroSpace — i3-style tiling window manager
  # Mod key: cmd+ctrl (hyper) - but with Caps Lock → cmd, this feels like SUPER
  home.file.".config/aerospace/aerospace.toml".text = ''
    # AeroSpace — https://nikitabobko.github.io/AeroSpace/
    config-version = 2
    start-at-login = true

    # 16px gaps between windows and at monitor edges
    gaps.inner.horizontal = 16
    gaps.inner.vertical = 16
    gaps.outer.left = 16
    gaps.outer.bottom = 16
    gaps.outer.top = 45
    gaps.outer.right = 16

    # Default layout for new workspaces
    default-root-container-layout = 'tiles'

    # Workspace names (Omarchy-style)
    persistent-workspaces = ['1-web', '2-code', '3-term', '4-chat', '5-media', '6-games', '7-docs', '8-sys', '9-vm', '10-misc']

    # Auto-assign apps to workspaces
    on-window-detected = [
      # 1 - Web Browsers
      { if = 'test %{app-bundle-id} = app.zen-browser.zen || test %{app-bundle-id} = org.torproject.torbrowser || test %{app-bundle-id} = com.apple.Safari || test %{app-bundle-id} = com.google.Chrome || test %{app-bundle-id} = org.mozilla.firefox', run = 'move-node-to-workspace 1-web' },
      # 2 - Code / AI
      { if = 'test %{app-bundle-id} = com.vscodium || test %{app-bundle-id} = ai.opencode.desktop || test %{app-bundle-id} = com.anthropic.claudefordesktop || test %{app-bundle-id} = ai.elementlabs.lmstudio || test %{app-bundle-id} = com.nousresearch.hermes.setup || test %{app-bundle-id} = com.apple.SFSymbols-beta || test %{app-bundle-id} = com.differentai.openwork || test %{app-bundle-id} = com.pi-gui.desktop || test %{app-bundle-id} = com.autodesk.dls.streamer.scriptapp.Autodesk-Fusion', run = 'move-node-to-workspace 2-code' },
      # 3 - Terminal / SSH
      { if = 'test %{app-bundle-id} = com.apple.Terminal || test %{app-bundle-id} = com.mitchellh.ghostty || test %{app-bundle-id} = com.googlecode.iterm2', run = 'move-node-to-workspace 3-term' },
      # 4 - Chat / Communication
      { if = 'test %{app-bundle-id} = org.whispersystems.signal-desktop || test %{app-bundle-id} = ru.keepcoder.Telegram || test %{app-bundle-id} = com.hnc.Discord || test %{app-bundle-id} = com.automattic.beeper.desktop || test %{app-bundle-id} = com.microsoft.teams2', run = 'move-node-to-workspace 4-chat' },
      # 5 - Media / Playback
      { if = 'test %{app-bundle-id} = com.colliderli.iina || test %{app-bundle-id} = org.tinyMediaManager.tinymediamanager || test %{app-bundle-id} = com.kiwifruitware.Burn || test %{app-bundle-id} = com.foobar2000.mac || test %{app-bundle-id} = jp.tmkk.XLD || test %{app-bundle-id} = org.musicbrainz.Picard || test %{app-bundle-id} = fm.last.Scrobbler || test %{app-bundle-id} = com.yourcompany.SoulseekQt || test %{app-bundle-id} = com.adobe.Photoshop || test %{app-bundle-id} = com.adobe.bridge', run = 'move-node-to-workspace 5-media' },
      # 6 - Games
      { if = 'test %{app-bundle-id} = com.valvesoftware.steam || test %{app-bundle-id} = org.prismlauncher.PrismLauncher || test %{app-bundle-id} = com.codeweavers.CrossOver || test %{app-bundle-id} = org.godotengine.godot || test %{app-bundle-id} = com.heroicgameslauncher.hgl', run = 'move-node-to-workspace 6-games' },
      # 7 - Docs / Notes
      { if = 'test %{app-bundle-id} = md.obsidian || test %{app-bundle-id} = md.obsidian.Obsidian-Web-Clipper || test %{app-bundle-id} = org.libreoffice.script || test %{app-bundle-id} = net.kovidgoyal.calibre || test %{app-bundle-id} = org.gramps-project.gramps || test %{app-bundle-id} = com.google.drivefs || test %{app-bundle-id} = com.google.drivefs.shortcuts.docs || test %{app-bundle-id} = com.google.drivefs.shortcuts.sheets || test %{app-bundle-id} = com.google.drivefs.shortcuts.slides || test %{app-bundle-id} = com.jonathan.glance', run = 'move-node-to-workspace 7-docs' },
      # 8 - Security / Utilities
      { if = 'test %{app-bundle-id} = org.keepassxc.keepassxc || test %{app-bundle-id} = org.idrix.VeraCrypt || test %{app-bundle-id} = com.yubico.yubioath || test %{app-bundle-id} = ch.protonvpn.mac || test %{app-bundle-id} = com.objective-see.lulu.app || test %{app-bundle-id} = com.objective-see.oversight || test %{app-bundle-id} = com.objective-see.KnockKnock || test %{app-bundle-id} = io.tailscale.ipn.macsys || test %{app-bundle-id} = com.cloudflare.1dot1dot1dot1.macos || test %{app-bundle-id} = com.alienator88.Pearcleaner || test %{app-bundle-id} = com.vorssaint.utils || test %{app-bundle-id} = eu.exelban.Stats || test %{app-bundle-id} = io.phonedeck.app.mac || test %{app-bundle-id} = org.herf.Flux || test %{app-bundle-id} = pro.betterdisplay.BetterDisplay || test %{app-bundle-id} = org.openlogi.openlogi || test %{app-bundle-id} = macos-wakatime.WakaTime || test %{app-bundle-id} = com.razorlabs.night-eye || test %{app-bundle-id} = se.oblador.Hush || test %{app-bundle-id} = com.adobe.acc.AdobeCreativeCloud', run = 'move-node-to-workspace 8-sys' },
      # 9 - VMs / Imaging
      { if = 'test %{app-bundle-id} = com.utmapp.UTM || test %{app-bundle-id} = com.docker.docker || test %{app-bundle-id} = io.balena.etcher', run = 'move-node-to-workspace 9-vm' },
      # 10 - Misc
      { if = 'test %{app-bundle-id} = com.apple.finder || test %{app-bundle-id} = com.apple.ActivityMonitor', run = 'move-node-to-workspace 10-misc' },
      # Floating: system settings / launchers / overlays must never tile
      { if = 'test %{app-bundle-id} = com.apple.systempreferences || test %{app-bundle-id} = com.raycast.macos || test %{app-bundle-id} = org.pqrs.Karabiner-Elements.Settings || test %{app-bundle-id} = org.pqrs.Karabiner-EventViewer || test %{app-bundle-id} = com.MrKai77.Loop || test %{app-bundle-id} = theboringteam.boringnotch || test %{app-bundle-id} = bobko.aerospace', run = ['layout floating'] },
    ]

    [mode.main.binding]
    # Mod = cmd+ctrl (hyper) - with Caps Lock → cmd via Karabiner, this is like SUPER
    # Focus
    cmd-ctrl-left = 'focus left'
    cmd-ctrl-down = 'focus down'
    cmd-ctrl-up = 'focus up'
    cmd-ctrl-right = 'focus right'

    # Move windows
    cmd-ctrl-shift-left = 'move left'
    cmd-ctrl-shift-down = 'move down'
    cmd-ctrl-shift-up = 'move up'
    cmd-ctrl-shift-right = 'move right'

    # Resize windows
    cmd-ctrl-alt-left = 'resize smart -20 0'
    cmd-ctrl-alt-down = 'resize smart 0 20'
    cmd-ctrl-alt-up = 'resize smart 0 -20'
    cmd-ctrl-alt-right = 'resize smart 20 0'

    # Workspaces (1-0)
    cmd-ctrl-1 = 'workspace 1-web'
    cmd-ctrl-2 = 'workspace 2-code'
    cmd-ctrl-3 = 'workspace 3-term'
    cmd-ctrl-4 = 'workspace 4-chat'
    cmd-ctrl-5 = 'workspace 5-media'
    cmd-ctrl-6 = 'workspace 6-games'
    cmd-ctrl-7 = 'workspace 7-docs'
    cmd-ctrl-8 = 'workspace 8-sys'
    cmd-ctrl-9 = 'workspace 9-vm'
    cmd-ctrl-0 = 'workspace 10-misc'

    # Move window to workspace
    cmd-ctrl-shift-1 = 'move-node-to-workspace 1-web'
    cmd-ctrl-shift-2 = 'move-node-to-workspace 2-code'
    cmd-ctrl-shift-3 = 'move-node-to-workspace 3-term'
    cmd-ctrl-shift-4 = 'move-node-to-workspace 4-chat'
    cmd-ctrl-shift-5 = 'move-node-to-workspace 5-media'
    cmd-ctrl-shift-6 = 'move-node-to-workspace 6-games'
    cmd-ctrl-shift-7 = 'move-node-to-workspace 7-docs'
    cmd-ctrl-shift-8 = 'move-node-to-workspace 8-sys'
    cmd-ctrl-shift-9 = 'move-node-to-workspace 9-vm'
    cmd-ctrl-shift-0 = 'move-node-to-workspace 10-misc'

    # Layouts / window ops
    cmd-ctrl-t = 'layout tiles'
    cmd-ctrl-a = 'layout accordion'
    cmd-ctrl-f = 'fullscreen'
    cmd-ctrl-w = 'close'
    cmd-ctrl-enter = 'exec-and-forget open -b com.mitchellh.ghostty'
    cmd-ctrl-space = 'exec-and-forget open -g raycast://'
    cmd-ctrl-b = 'exec-and-forget open -b app.zen-browser.zen'
    cmd-ctrl-tab = 'focus dfs-next'
    cmd-ctrl-shift-tab = 'focus dfs-prev'

    # Floating toggle
    cmd-ctrl-shift-space = 'toggle-floating'

    # Scratchpad (special workspace)
    cmd-ctrl-grave = 'workspace scratchpad'
    cmd-ctrl-shift-grave = 'move-node-to-workspace scratchpad'

    # Screenshot
    cmd-ctrl-shift-4 = 'exec-and-forget screencapture -i ~/Pictures/Screenshots/screenshot-$(date +%s).png'

    # Reload config
    cmd-ctrl-shift-r = 'exec-and-forget aerospace reload-config'

    # Quit AeroSpace
    cmd-ctrl-shift-q = 'exec-and-forget aerospace quit'
  '';

  # macOS-specific shell aliases
  programs.zsh.shellAliases = {
    # Theme
    theme = "tundra-theme";
    themes = "tundra-theme list";
    # AI
    ai = "opencode";
    # claude = "claude-code";  # Not in Homebrew - install via npm: npm i -g @anthropic-ai/claude-code
    antigravity = "agy";
    gemini = "agy";
    # copilot = "copilot-cli";  # Not in Homebrew - install via npm: npm i -g @github/copilot-cli
  };

  # macOS-specific update function
  programs.zsh.initContent = lib.mkOrder 600 ''
    update-all() {
        rbu
    }

    # Source AI keys if present
    [ -f "$HOME/.config/ai-keys.sh" ] && source "$HOME/.config/ai-keys.sh"
  '';
}
