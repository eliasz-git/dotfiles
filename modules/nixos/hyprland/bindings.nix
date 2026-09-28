{ config, lib, pkgs, ... }:

let
  # Omarchy-style keybindings for Hyprland
  # $mod = SUPER (Caps Lock mapped via input.nix)
  bindings = [
    # ── Core ────────────────────────────────────────────────────────
    "$mod, Return, exec, foot"
    "$mod, Space, exec, wofi --show drun"
    "$mod, B, exec, zen-beta"
    "$mod, E, exec, thunar"
    "$mod, V, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy"
    "$mod, Q, killactive,"
    "$mod, Shift, E, exit,"
    "$mod, F, fullscreen,"
    "$mod, T, togglefloating,"
    "$mod, G, exec, gamescope -w 1920 -h 1080 -r 120 -- steam"
    "$mod, M, exec, foot -e rmpc"
    "$mod, Print, exec, grim -g \"$(slurp)\" - | wl-copy"
    "$mod, Shift, Print, exec, grim - | wl-copy"
    "$mod, Ctrl, Print, exec, wf-recorder -g \"$(slurp)\" -f \"$HOME/Videos/recording-$(date +%s).mp4\""
    "$mod, Ctrl, Shift, Print, exec, pkill -INT wf-recorder"

    # ── Workspaces ──────────────────────────────────────────────────
    "$mod, 1, workspace, 1"
    "$mod, 2, workspace, 2"
    "$mod, 3, workspace, 3"
    "$mod, 4, workspace, 4"
    "$mod, 5, workspace, 5"
    "$mod, 6, workspace, 6"
    "$mod, 7, workspace, 7"
    "$mod, 8, workspace, 8"
    "$mod, 9, workspace, 9"
    "$mod, 0, workspace, 10"

    "$mod, Shift, 1, movetoworkspace, 1"
    "$mod, Shift, 2, movetoworkspace, 2"
    "$mod, Shift, 3, movetoworkspace, 3"
    "$mod, Shift, 4, movetoworkspace, 4"
    "$mod, Shift, 5, movetoworkspace, 5"
    "$mod, Shift, 6, movetoworkspace, 6"
    "$mod, Shift, 7, movetoworkspace, 7"
    "$mod, Shift, 8, movetoworkspace, 8"
    "$mod, Shift, 9, movetoworkspace, 9"
    "$mod, Shift, 0, movetoworkspace, 10"

    # ── Navigation ──────────────────────────────────────────────────
    "$mod, left, movefocus, l"
    "$mod, right, movefocus, r"
    "$mod, up, movefocus, u"
    "$mod, down, movefocus, d"

    "$mod, h, movefocus, l"
    "$mod, l, movefocus, r"
    "$mod, k, movefocus, u"
    "$mod, j, movefocus, d"

    # ── Window Movement ─────────────────────────────────────────────
    "$mod, Shift, left, movewindow, l"
    "$mod, Shift, right, movewindow, r"
    "$mod, Shift, up, movewindow, u"
    "$mod, Shift, down, movewindow, d"

    "$mod, Shift, h, movewindow, l"
    "$mod, Shift, l, movewindow, r"
    "$mod, Shift, k, movewindow, u"
    "$mod, Shift, j, movewindow, d"

    # ── Resizing ────────────────────────────────────────────────────
    "$mod, Ctrl, left, resizeactive, -50 0"
    "$mod, Ctrl, right, resizeactive, 50 0"
    "$mod, Ctrl, up, resizeactive, 0 -50"
    "$mod, Ctrl, down, resizeactive, 0 50"

    "$mod, Ctrl, h, resizeactive, -50 0"
    "$mod, Ctrl, l, resizeactive, 50 0"
    "$mod, Ctrl, k, resizeactive, 0 -50"
    "$mod, Ctrl, j, resizeactive, 0 50"

    # ── Layouts ─────────────────────────────────────────────────────
    "$mod, Tab, cyclenext,"
    "$mod, Shift, Tab, cyclenextprev,"
    "$mod, grave, togglegroup,"
    "$mod, Shift, grave, changegroupactive,"
    "$mod, R, layoutmsg, dwindlesplit"
    "$mod, Shift, R, layoutmsg, master"

    # ── Floating ────────────────────────────────────────────────────
    "$mod, Shift, Space, togglefloating,"
    "$mod, Ctrl, Space, togglefullscreen,"

    # ── Special Workspace (scratchpad) ──────────────────────────────
    "$mod, S, togglespecialworkspace, magic"
    "$mod, Shift, S, movetoworkspace, special:magic"

    # ── Media Keys ──────────────────────────────────────────────────
    ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
    ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
    ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
    ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
    ", XF86AudioPlay, exec, playerctl play-pause"
    ", XF86AudioPause, exec, playerctl play-pause"
    ", XF86AudioNext, exec, playerctl next"
    ", XF86AudioPrev, exec, playerctl previous"
    ", XF86AudioStop, exec, playerctl stop"
    ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
    ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
    ", XF86Calculator, exec, foot -e python3 -ic \"from math import *; print(eval(input('> ')))\""
    ", XF86Sleep, exec, systemctl suspend"
    ", XF86PowerOff, exec, wlogout"

    # ── Screenshot/Recording (additional) ───────────────────────────
    "$mod, Shift, Print, exec, grim - | wl-copy"
    "$mod, Ctrl, Print, exec, swappy -f -"

    # ── Application Launchers ───────────────────────────────────────
    "$mod, C, exec, foot -e opencode"
    "$mod, D, exec, foot -e claude-code"
    "$mod, X, exec, foot -e gemini-cli"
    "$mod, Z, exec, foot -e copilot-cli"
    "$mod, N, exec, foot -e nnn"
    "$mod, I, exec, foot -e htop"
    "$mod, P, exec, pavucontrol"
    "$mod, U, exec, foot -e nvim"
    "$mod, Y, exec, foot -e lazygit"
    "$mod, O, exec, obsidian"
    "$mod, K, exec, keepassxc"
    "$mod, L, exec, foot -e lf"

    # ── Gaming ──────────────────────────────────────────────────────
    "$mod, Shift, G, exec, gamescope -w 1920 -h 1080 -r 120 -- steam"
    "$mod, Shift, H, exec, heroic"
    "$mod, Shift, B, exec, bottles"
    "$mod, Shift, L, exec, lutris"

    # ── System ──────────────────────────────────────────────────────
    "$mod, Shift, Q, exec, wlogout"
    "$mod, Shift, R, exec, sudo nixos-rebuild switch --flake ~/.config/nix-config#gaming-pc"
    "$mod, Shift, U, exec, cd ~/.config/nix-config && nix flake update && sudo nixos-rebuild switch --flake .#gaming-pc"

    # ── Mouse Bindings ──────────────────────────────────────────────
    # $mod + left click = move window
    # $mod + right click = resize window
    # $mod + middle click = toggle floating
  ];

in {
  wayland.windowManager.hyprland.settings.bind = bindings;

  # Mouse bindings
  wayland.windowManager.hyprland.settings.bindm = [
    "$mod, mouse:272, movewindow"
    "$mod, mouse:273, resizewindow"
    "$mod, mouse:274, togglefloating"
  ];
}