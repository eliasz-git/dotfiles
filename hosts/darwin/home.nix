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
        { if = 'test %{app-bundle-id} = org.mozilla.firefox || test %{app-bundle-id} = app.zen-browser.zen || test %{app-bundle-id} = org.torproject.torbrowser', run = 'move-node-to-workspace 1-browsers' },
        # 2 - Chat
        { if = 'test %{app-bundle-id} = org.whispersystems.signal-desktop || test %{app-bundle-id} = ru.keepcoder.Telegram || test %{app-bundle-id} = com.hnc.Discord || test %{app-bundle-id} = com.automattic.beeper.desktop || test %{app-bundle-id} = com.microsoft.teams2', run = 'move-node-to-workspace 2-chat' },
        # 3 - Mail / news
        { if = 'test %{app-bundle-id} = org.mozilla.thunderbird || test %{app-bundle-id} = de.tutao.tutanota || test %{app-bundle-id} = com.ranchero.NetNewsWire-Evergreen', run = 'move-node-to-workspace 3-mail' },
        # 4 - Code / AI
        { if = 'test %{app-bundle-id} = com.vscodium || test %{app-bundle-id} = dev.zed.Zed || test %{app-bundle-id} = ai.opencode.desktop || test %{app-bundle-id} = com.anthropic.claudefordesktop || test %{app-bundle-id} = com.jetbrains.toolbox || test %{app-bundle-id} = com.termius-dmg.mac || test %{app-bundle-id} = jan.ai.app || test %{app-bundle-id} = ai.elementlabs.lmstudio || test %{app-bundle-id} = com.nousresearch.hermes', run = 'move-node-to-workspace 4-code' },
        # 5 - Terminal
        { if = 'test %{app-bundle-id} = com.apple.Terminal', run = 'move-node-to-workspace 5-terminal' },
        # 6 - Docs / notes
        { if = 'test %{app-bundle-id} = md.obsidian || test %{app-bundle-id} = org.libreoffice.script || test %{app-bundle-id} = net.kovidgoyal.calibre || test %{app-bundle-id} = org.gramps-project.gramps', run = 'move-node-to-workspace 6-docs' },
        # 7 - Media
        { if = 'test %{app-bundle-id} = com.colliderli.iina || test %{app-bundle-id} = com.github.th-ch.youtube-music || test %{app-bundle-id} = com.futo.grayjay.desktop || test %{app-bundle-id} = org.tinyMediaManager.tinymediamanager', run = 'move-node-to-workspace 7-media' },
        # 8 - Games
        { if = 'test %{app-bundle-id} = com.valvesoftware.steam || test %{app-bundle-id} = org.prismlauncher.PrismLauncher || test %{app-bundle-id} = com.codeweavers.CrossOver', run = 'move-node-to-workspace 8-games' },
        # 9 - Security / utilities
        { if = 'test %{app-bundle-id} = org.keepassxc.keepassxc || test %{app-bundle-id} = com.bitwarden.desktop || test %{app-bundle-id} = org.idrix.VeraCrypt || test %{app-bundle-id} = com.yubico.yubioath || test %{app-bundle-id} = ch.protonvpn.mac || test %{app-bundle-id} = com.objective-see.lulu.app || test %{app-bundle-id} = com.objective-see.oversight || test %{app-bundle-id} = com.objective-see.KnockKnock || test %{app-bundle-id} = com.carriez.rustdesk || test %{app-bundle-id} = io.tailscale.ipn.macsys', run = 'move-node-to-workspace 9-security' },
        # 10 - VMs
        { if = 'test %{app-bundle-id} = com.utmapp.UTM || test %{app-bundle-id} = com.docker.docker', run = 'move-node-to-workspace 10-vms' },
        # Floating: system settings / launchers must never tile
        { if = 'test %{app-bundle-id} = com.apple.systempreferences || test %{app-bundle-id} = com.raycast.macos || test %{app-bundle-id} = org.pqrs.Karabiner-Elements.Settings', run = ['layout floating'] },
      ]

      [mode.main.binding]
      # Focus
      alt-left = 'focus left'
      alt-down = 'focus down'
      alt-up = 'focus up'
      alt-right = 'focus right'

      # Move windows
      alt-shift-left = 'move left'
      alt-shift-down = 'move down'
      alt-shift-up = 'move up'
      alt-shift-right = 'move right'

      # Workspaces
      alt-1 = 'workspace 1-browsers'
      alt-2 = 'workspace 2-chat'
      alt-3 = 'workspace 3-mail'
      alt-4 = 'workspace 4-code'
      alt-5 = 'workspace 5-terminal'
      alt-6 = 'workspace 6-docs'
      alt-7 = 'workspace 7-media'
      alt-8 = 'workspace 8-games'
      alt-9 = 'workspace 9-security'
      alt-0 = 'workspace 10-vms'

      # Move window to workspace
      alt-shift-1 = 'move-node-to-workspace 1-browsers'
      alt-shift-2 = 'move-node-to-workspace 2-chat'
      alt-shift-3 = 'move-node-to-workspace 3-mail'
      alt-shift-4 = 'move-node-to-workspace 4-code'
      alt-shift-5 = 'move-node-to-workspace 5-terminal'
      alt-shift-6 = 'move-node-to-workspace 6-docs'
      alt-shift-7 = 'move-node-to-workspace 7-media'
      alt-shift-8 = 'move-node-to-workspace 8-games'
      alt-shift-9 = 'move-node-to-workspace 9-security'
      alt-shift-0 = 'move-node-to-workspace 10-vms'

      # Layouts / window ops
      alt-t = 'layout tiles'
      alt-a = 'layout accordion'
      alt-f = 'fullscreen'
      alt-w = 'close'
      alt-enter = 'exec-and-forget open -a Terminal'
      alt-tab = 'focus dfs-next'
      alt-shift-tab = 'focus dfs-prev'
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
