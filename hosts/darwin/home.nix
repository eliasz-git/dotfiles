{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/shared/programs.nix
    ../../modules/shared/shell.nix
    ../../modules/shared/git.nix
    ../../modules/shared/multiplexer.nix
    ../../modules/shared/fastfetch.nix
    ../../modules/darwin/terminal.nix
  ];

  home.stateVersion = "25.05";
  programs.home-manager.enable = true;

  # Same for karabiner — keeps keyboard remaps under version control
  home.file.".config/karabiner".source =
    config.lib.file.mkOutOfStoreSymlink
      "/Users/elias/.config/nix-config/modules/darwin/karabiner";

  # AeroSpace — i3-style tiling window manager
    home.file.".config/aerospace/aerospace.toml".text = ''
      # AeroSpace — https://nikitabobko.github.io/AeroSpace/
      config-version = 2
      start-at-login = true

      # 8px gaps between windows and at monitor edges
      gaps.inner.horizontal = 8
      gaps.inner.vertical = 8
      gaps.outer.left = 8
      gaps.outer.bottom = 8
      gaps.outer.top = 8
      gaps.outer.right = 8

      # Default layout for new workspaces
      default-root-container-layout = 'tiles'

      # Auto-assign apps to workspaces (alt+1..0)
      persistent-workspaces = ['1-browsers', '2-chat', '3-mail', '4-code', '5-terminal', '6-docs', '7-media', '8-games', '9-security', '10-vms']
      on-window-detected = [
        # 1 - Browsers
        { if = 'test %{app-bundle-id} = org.mozilla.firefox || test %{app-bundle-id} = com.apple.Safari || test %{app-bundle-id} = com.browseros.BrowserClaw', run = 'move-node-to-workspace 1-browsers' },
        # 2 - Chat
        { if = 'test %{app-bundle-id} = com.hnc.Discord || test %{app-bundle-id} = com.automattic.beeper.desktop || test %{app-bundle-id} = com.microsoft.teams2 || test %{app-bundle-id} = com.apple.FaceTime', run = 'move-node-to-workspace 2-chat' },
        # 3 - Mail / news
        { if = 'test %{app-bundle-id} = de.tutao.tutanota || test %{app-bundle-id} = com.ranchero.NetNewsWire-Evergreen || test %{app-bundle-id} = com.apple.mail || test %{app-bundle-id} = com.apple.news', run = 'move-node-to-workspace 3-mail' },
        # 4 - Code / AI
        { if = 'test %{app-bundle-id} = com.vscodium || test %{app-bundle-id} = dev.zed.Zed || test %{app-bundle-id} = ai.opencode.desktop || test %{app-bundle-id} = com.anthropic.claudefordesktop || test %{app-bundle-id} = com.nousresearch.hermes || test %{app-bundle-id} = macos-wakatime.WakaTime', run = 'move-node-to-workspace 4-code' },
        # 5 - Terminal / SSH
        { if = 'test %{app-bundle-id} = com.apple.Terminal || test %{app-bundle-id} = com.termius-dmg.mac || test %{app-bundle-id} = org.alacritty', run = 'move-node-to-workspace 5-terminal' },
        # 6 - Docs / notes
        { if = 'test %{app-bundle-id} = md.obsidian || test %{app-bundle-id} = net.kovidgoyal.calibre || test %{app-bundle-id} = org.gramps-project.gramps || test %{app-bundle-id} = md.obsidian.Obsidian-Web-Clipper || test %{app-bundle-id} = com.apple.Notes || test %{app-bundle-id} = com.apple.reminders || test %{app-bundle-id} = com.apple.iCal || test %{app-bundle-id} = com.apple.iBooksX || test %{app-bundle-id} = com.apple.Preview || test %{app-bundle-id} = com.apple.TextEdit || test %{app-bundle-id} = com.apple.freeform || test %{app-bundle-id} = com.apple.Stickies || test %{app-bundle-id} = com.apple.journal || test %{app-bundle-id} = com.apple.Dictionary', run = 'move-node-to-workspace 6-docs' },
        # 7 - Media / playback
        { if = 'test %{app-bundle-id} = com.colliderli.iina || test %{app-bundle-id} = com.github.th-ch.youtube-music || test %{app-bundle-id} = com.futo.grayjay.desktop || test %{app-bundle-id} = org.tinyMediaManager.tinymediamanager || test %{app-bundle-id} = com.kiwifruitware.Burn || test %{app-bundle-id} = com.apple.Music || test %{app-bundle-id} = com.apple.podcasts || test %{app-bundle-id} = com.apple.TV || test %{app-bundle-id} = com.apple.QuickTimePlayerX || test %{app-bundle-id} = com.apple.VoiceMemos || test %{app-bundle-id} = com.apple.PhotoBooth || test %{app-bundle-id} = com.apple.Photos', run = 'move-node-to-workspace 7-media' },
        # 8 - Games
        { if = 'test %{app-bundle-id} = com.valvesoftware.steam || test %{app-bundle-id} = org.prismlauncher.PrismLauncher || test %{app-bundle-id} = com.codeweavers.CrossOver || test %{app-bundle-id} = com.apple.Chess || test %{app-bundle-id} = com.apple.games', run = 'move-node-to-workspace 8-games' },
        # 9 - Security / utilities (iMessage lives here so it stops popping up with Beeper)
        { if = 'test %{app-bundle-id} = org.keepassxc.keepassxc || test %{app-bundle-id} = org.idrix.VeraCrypt || test %{app-bundle-id} = com.yubico.yubioath || test %{app-bundle-id} = com.objective-see.lulu.app || test %{app-bundle-id} = com.carriez.rustdesk || test %{app-bundle-id} = io.tailscale.ipn.macsys || test %{app-bundle-id} = com.cloudflare.1dot1dot1dot1.macos || test %{app-bundle-id} = com.alienator88.Pearcleaner || test %{app-bundle-id} = com.vorssaint.utils || test %{app-bundle-id} = io.phonedeck.app.mac || test %{app-bundle-id} = com.apple.MobileSMS || test %{app-bundle-id} = com.apple.Passwords || test %{app-bundle-id} = com.apple.findmy || test %{app-bundle-id} = com.apple.ScreenContinuity || test %{app-bundle-id} = com.apple.Maps || test %{app-bundle-id} = com.apple.weather || test %{app-bundle-id} = com.apple.clock || test %{app-bundle-id} = com.apple.stocks || test %{app-bundle-id} = com.apple.calculator || test %{app-bundle-id} = com.apple.Home', run = 'move-node-to-workspace 9-security' },
        # 10 - VMs / imaging
        { if = 'test %{app-bundle-id} = com.docker.docker || test %{app-bundle-id} = io.balena.etcher', run = 'move-node-to-workspace 10-vms' },
        # Floating: system settings / launchers / overlays must never tile
        { if = 'test %{app-bundle-id} = com.apple.systempreferences || test %{app-bundle-id} = com.raycast.macos || test %{app-bundle-id} = org.pqrs.Karabiner-Elements.Settings || test %{app-bundle-id} = org.pqrs.Karabiner-EventViewer || test %{app-bundle-id} = theboringteam.boringnotch || test %{app-bundle-id} = bobko.aerospace || test %{app-bundle-id} = net.raymondhill.uBlock-Origin-Lite', run = ['layout floating'] },
      ]

      [mode.main.binding]
      # Focus (caps lock = hyper = cmd+ctrl)
      cmd-ctrl-left = 'focus left'
      cmd-ctrl-down = 'focus down'
      cmd-ctrl-up = 'focus up'
      cmd-ctrl-right = 'focus right'

      # Move windows
      cmd-ctrl-shift-left = 'move left'
      cmd-ctrl-shift-down = 'move down'
      cmd-ctrl-shift-up = 'move up'
      cmd-ctrl-shift-right = 'move right'

      # Workspaces
      cmd-ctrl-1 = 'workspace 1-browsers'
      cmd-ctrl-2 = 'workspace 2-chat'
      cmd-ctrl-3 = 'workspace 3-mail'
      cmd-ctrl-4 = 'workspace 4-code'
      cmd-ctrl-5 = 'workspace 5-terminal'
      cmd-ctrl-6 = 'workspace 6-docs'
      cmd-ctrl-7 = 'workspace 7-media'
      cmd-ctrl-8 = 'workspace 8-games'
      cmd-ctrl-9 = 'workspace 9-security'
      cmd-ctrl-0 = 'workspace 10-vms'

      # Move window to workspace
      cmd-ctrl-shift-1 = 'move-node-to-workspace 1-browsers'
      cmd-ctrl-shift-2 = 'move-node-to-workspace 2-chat'
      cmd-ctrl-shift-3 = 'move-node-to-workspace 3-mail'
      cmd-ctrl-shift-4 = 'move-node-to-workspace 4-code'
      cmd-ctrl-shift-5 = 'move-node-to-workspace 5-terminal'
      cmd-ctrl-shift-6 = 'move-node-to-workspace 6-docs'
      cmd-ctrl-shift-7 = 'move-node-to-workspace 7-media'
      cmd-ctrl-shift-8 = 'move-node-to-workspace 8-games'
      cmd-ctrl-shift-9 = 'move-node-to-workspace 9-security'
      cmd-ctrl-shift-0 = 'move-node-to-workspace 10-vms'

      # Layouts / window ops
      cmd-ctrl-t = 'layout tiles'
      cmd-ctrl-a = 'layout accordion'
      cmd-ctrl-f = 'fullscreen'
      cmd-ctrl-w = 'close'
      cmd-ctrl-enter = 'exec-and-forget open -a Terminal'
      cmd-ctrl-tab = 'focus dfs-next'
      cmd-ctrl-shift-tab = 'focus dfs-prev'
    '';

  # macOS-specific shell aliases
  programs.zsh.shellAliases = {
    darwin-rebuild = "sudo darwin-rebuild switch --flake ~/.config/nix-config#macbook";
    darwin-update = "cd ~/.config/nix-config && nix flake update && sudo darwin-rebuild switch --flake .#macbook";
  };

  # macOS-specific update function
  programs.zsh.initContent = lib.mkOrder 600 ''
    update-all() {
        echo "Updating Nix flake..."
        cd ~/.config/nix-config
        nix flake update

        echo "Rebuilding macOS system..."
        sudo darwin-rebuild switch --flake ~/.config/nix-config#macbook
    }
  '';
}
