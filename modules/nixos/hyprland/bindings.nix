{ config, lib, pkgs, ... }:

let
  # Omarchy-style keybindings for Hyprland
  # $mod = SUPER (Caps Lock mapped via input.nix)
  bindings = [
    # ── Core ────────────────────────────────────────────────────────
    "SUPER, Return, exec, foot"
    "SUPER, Space, exec, rofi -show drun"
    "SUPER, W, exec, rofi -show window"
    "SUPER, D, exec, rofi -show ssh"
    "SUPER ALT, C, exec, rofi -show calc"
    "SUPER ALT, E, exec, rofi -show emoji"
    "SUPER, B, exec, zen-beta"
    "SUPER, E, exec, thunar"
    "SUPER, V, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy"
    "SUPER, Q, killactive,"
    "SUPER SHIFT, E, exit,"
    "SUPER, F, fullscreen,"
    "SUPER, T, togglefloating,"
    "SUPER, G, exec, gamescope -w 1920 -h 1080 -r 120 -- steam"
    "SUPER, M, exec, foot -e rmpc"
    "SUPER, Print, exec, grim -g \"$(slurp)\" - | wl-copy"
    "SUPER SHIFT, Print, exec, grim - | wl-copy"
    "SUPER CTRL, Print, exec, wf-recorder -g \"$(slurp)\" -f \"$HOME/Videos/recording-$(date +%s).mp4\""
    "SUPER CTRL SHIFT, Print, exec, pkill -INT wf-recorder"
    "SUPER ALT, Print, exec, grim -g \"$(slurp)\" - | swappy -f -"
    "SUPER, S, exec, grim -g \"$(slurp)\" - | wl-copy"
    "SUPER SHIFT, S, exec, grim - | wl-copy"
    "SUPER CTRL, S, exec, wf-recorder -g \"$(slurp)\" -f \"$HOME/Videos/recording-$(date +%s).mp4\""
    "SUPER CTRL SHIFT, S, exec, pkill -INT wf-recorder"

    # ── Workspaces ──────────────────────────────────────────────────
    "SUPER, 1, workspace, 1"
    "SUPER, 2, workspace, 2"
    "SUPER, 3, workspace, 3"
    "SUPER, 4, workspace, 4"
    "SUPER, 5, workspace, 5"
    "SUPER, 6, workspace, 6"
    "SUPER, 7, workspace, 7"
    "SUPER, 8, workspace, 8"
    "SUPER, 9, workspace, 9"
    "SUPER, 0, workspace, 10"

    "SUPER SHIFT, 1, movetoworkspace, 1"
    "SUPER SHIFT, 2, movetoworkspace, 2"
    "SUPER SHIFT, 3, movetoworkspace, 3"
    "SUPER SHIFT, 4, movetoworkspace, 4"
    "SUPER SHIFT, 5, movetoworkspace, 5"
    "SUPER SHIFT, 6, movetoworkspace, 6"
    "SUPER SHIFT, 7, movetoworkspace, 7"
    "SUPER SHIFT, 8, movetoworkspace, 8"
    "SUPER SHIFT, 9, movetoworkspace, 9"
    "SUPER SHIFT, 0, movetoworkspace, 10"

    # ── Navigation ──────────────────────────────────────────────────
    "SUPER, left, movefocus, l"
    "SUPER, right, movefocus, r"
    "SUPER, up, movefocus, u"
    "SUPER, down, movefocus, d"
    "SUPER, mouse_down, workspace, e+1"
    "SUPER, mouse_up, workspace, e-1"
    # Hyprland 0.55+ does not deliver modifier + pointer binds, so the scroll
    # wheel path above needs a keyboard equivalent.
    "SUPER SHIFT, bracketright, workspace, e+1"
    "SUPER SHIFT, bracketleft, workspace, e-1"

    "SUPER, h, movefocus, l"
    "SUPER, l, movefocus, r"
    "SUPER, k, movefocus, u"
    "SUPER, j, movefocus, d"

    # ── Window Movement ─────────────────────────────────────────────
    "SUPER SHIFT, left, movewindow, l"
    "SUPER SHIFT, right, movewindow, r"
    "SUPER SHIFT, up, movewindow, u"
    "SUPER SHIFT, down, movewindow, d"

    "SUPER SHIFT, h, movewindow, l"
    "SUPER SHIFT, l, movewindow, r"
    "SUPER SHIFT, k, movewindow, u"
    "SUPER SHIFT, j, movewindow, d"

    # ── Resizing ────────────────────────────────────────────────────
    "SUPER CTRL, left, resizeactive, -50 0"
    "SUPER CTRL, right, resizeactive, 50 0"
    "SUPER CTRL, up, resizeactive, 0 -50"
    "SUPER CTRL, down, resizeactive, 0 50"

    "SUPER CTRL, h, resizeactive, -50 0"
    "SUPER CTRL, l, resizeactive, 50 0"
    "SUPER CTRL, k, resizeactive, 0 -50"
    "SUPER CTRL, j, resizeactive, 0 50"

    # ── Layouts ─────────────────────────────────────────────────────
    "SUPER, Tab, cyclenext,"
    "SUPER SHIFT, Tab, cyclenext, prev"
    "SUPER, grave, togglegroup,"
    "SUPER SHIFT, grave, changegroupactive,"
    "SUPER, R, layoutmsg, dwindlesplit"
    "SUPER SHIFT, R, layoutmsg, master"

    # ── Floating ────────────────────────────────────────────────────
    "SUPER SHIFT, Space, togglefloating,"
    "SUPER CTRL, Space, fullscreen, 0"

    # ── Special Workspace (scratchpad) ──────────────────────────────
    "SUPER, F12, togglespecialworkspace, magic"
    "SUPER SHIFT, F12, movetoworkspace, special:magic"

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

    # ── Application Launchers ───────────────────────────────────────
    "SUPER, C, exec, foot -e opencode"
    "SUPER, X, exec, foot -e agy"
    "SUPER, N, exec, foot -e nnn"
    "SUPER, I, exec, foot -e htop"
    "SUPER, P, exec, pavucontrol"
    "SUPER, U, exec, foot -e nvim"
    "SUPER, Y, exec, foot -e lazygit"
    "SUPER, O, exec, obsidian"
    "SUPER ALT, K, exec, keepassxc"
    "SUPER ALT, F, exec, foot -e lf"

    # ── Gaming ──────────────────────────────────────────────────────
    "SUPER SHIFT, G, exec, gamescope -w 1920 -h 1080 -r 120 -- steam"
    "SUPER ALT, H, exec, heroic"
    "SUPER SHIFT, B, exec, bottles"
    "SUPER ALT, L, exec, lutris"

    # ── System ──────────────────────────────────────────────────────
    "SUPER SHIFT, Q, exec, wlogout"
    "SUPER CTRL SHIFT, R, exec, sudo nixos-rebuild switch --flake ~/.config/nix-config#gaming-pc"
    "SUPER SHIFT, U, exec, foot -e tundra rbu"
  ];

in {
  wayland.windowManager.hyprland.settings.bind = bindings;
}
