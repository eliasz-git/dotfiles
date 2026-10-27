{ config, lib, pkgs, ... }:

let
  # Omarchy-style keybindings for Mango.
  # $mod = SUPER (Caps Lock mapped via input.nix: xkb_rules_options = caps:super).
  # Mango joins multiple modifiers with '+', i.e. SUPER+CTRL (Hyprland's
  # SUPER CTRL syntax becomes SUPER+CTRL).
  bindings = [
    # ── Core ────────────────────────────────────────────────────────
    "SUPER,Return,spawn,foot"
    "SUPER,Space,spawn,rofi -show drun"
    "SUPER,Escape,spawn,tundra-screensaver"
    "SUPER,w,spawn,rofi -show window"
    "SUPER,d,spawn,rofi -show ssh"
    "SUPER+ALT,c,spawn,rofi -show calc"
    "SUPER+ALT,e,spawn,rofi -show emoji"
    "SUPER,b,spawn,zen-beta"
    "SUPER,e,spawn,thunar"
    # cliphist piping needs a shell, spawn_shell supports pipes.
    "SUPER,v,spawn_shell,cliphist list | rofi -dmenu | cliphist decode | wl-copy"
    "SUPER,q,killclient,"
    "SUPER+SHIFT,e,quit,"
    "SUPER,f,togglefullscreen,"
    "SUPER,t,togglefloating,"
    "SUPER,g,spawn,gamescope -w 1920 -h 1080 -r 120 -- steam"
    "SUPER,m,spawn,foot -e rmpc"

    # ── Screenshots ─────────────────────────────────────────────────
    "SUPER,Print,spawn_shell,grim -g \"$(slurp)\" - | wl-copy"
    "SUPER+SHIFT,Print,spawn_shell,grim - | wl-copy"
    "SUPER+CTRL,Print,spawn_shell,wf-recorder -g \"$(slurp)\" -f \"$HOME/Videos/recording-$(date +%s).mp4\""
    "SUPER+CTRL+SHIFT,Print,spawn_shell,pkill -INT wf-recorder"
    "SUPER+ALT,Print,spawn_shell,grim -g \"$(slurp)\" - | swappy -f -"
    "SUPER,s,spawn_shell,grim -g \"$(slurp)\" - | wl-copy"
    "SUPER+SHIFT,s,spawn_shell,grim - | wl-copy"
    "SUPER+CTRL,s,spawn_shell,wf-recorder -g \"$(slurp)\" -f \"$HOME/Videos/recording-$(date +%s).mp4\""
    "SUPER+CTRL+SHIFT,s,spawn_shell,pkill -INT wf-recorder"

    # ── Tags (workspaces) ───────────────────────────────────────────
    # Mango has 9 tags by default (tag_num=9). Tag 0 is the special
    # workspace overlay. Hyprland had workspaces 1-10; 10 is dropped.
    "SUPER,1,view,1"
    "SUPER,2,view,2"
    "SUPER,3,view,3"
    "SUPER,4,view,4"
    "SUPER,5,view,5"
    "SUPER,6,view,6"
    "SUPER,7,view,7"
    "SUPER,8,view,8"
    "SUPER,9,view,9"

    "SUPER+SHIFT,1,tag,1"
    "SUPER+SHIFT,2,tag,2"
    "SUPER+SHIFT,3,tag,3"
    "SUPER+SHIFT,4,tag,4"
    "SUPER+SHIFT,5,tag,5"
    "SUPER+SHIFT,6,tag,6"
    "SUPER+SHIFT,7,tag,7"
    "SUPER+SHIFT,8,tag,8"
    "SUPER+SHIFT,9,tag,9"

    # ── Navigation ──────────────────────────────────────────────────
    "SUPER,left,focusdir,left"
    "SUPER,right,focusdir,right"
    "SUPER,up,focusdir,up"
    "SUPER,down,focusdir,down"
    "SUPER,h,focusdir,left"
    "SUPER,l,focusdir,right"
    "SUPER,k,focusdir,up"
    "SUPER,j,focusdir,down"
    # Keyboard tag cycling (Mango does not deliver modifier+pointer binds).
    "SUPER+SHIFT,bracketright,viewtoright"
    "SUPER+SHIFT,bracketleft,viewtoleft"

    # ── Window Movement ─────────────────────────────────────────────
    "SUPER+SHIFT,left,move_client,left"
    "SUPER+SHIFT,right,move_client,right"
    "SUPER+SHIFT,up,move_client,up"
    "SUPER+SHIFT,down,move_client,down"
    "SUPER+SHIFT,h,move_client,left"
    "SUPER+SHIFT,l,move_client,right"
    "SUPER+SHIFT,k,move_client,up"
    "SUPER+SHIFT,j,move_client,down"

    # ── Resizing ────────────────────────────────────────────────────
    # resizewin takes signed width/height offsets, e.g. -50,+0.
    "SUPER+CTRL,left,resizewin,-50,+0"
    "SUPER+CTRL,right,resizewin,+50,+0"
    "SUPER+CTRL,up,resizewin,+0,-50"
    "SUPER+CTRL,down,resizewin,+0,+50"
    "SUPER+CTRL,h,resizewin,-50,+0"
    "SUPER+CTRL,l,resizewin,+50,+0"
    "SUPER+CTRL,k,resizewin,+0,-50"
    "SUPER+CTRL,j,resizewin,+0,+50"

    # ── Layouts ─────────────────────────────────────────────────────
    # focusstack next/prev replaces Hyprland cyclenext (+ prev).
    "SUPER,Tab,focusstack,next"
    "SUPER+SHIFT,Tab,focusstack,prev"
    # Dwindle split toggle; SUPER+SHIFT+R cycles dwindle ↔ master-stack
    # (circle_layout below). Hyprland's togglegroup has no exact mango
    # equivalent; groupjoin/groupfocus are the closest.
    "SUPER,grave,groupjoin,up"
    "SUPER+SHIFT,grave,groupfocus,next"
    "SUPER,r,dwindle_toggle_split_direction,"
    "SUPER+SHIFT,r,switch_layout,"

    # ── Floating ────────────────────────────────────────────────────
    "SUPER+SHIFT,Space,togglefloating,"
    "SUPER+CTRL,Space,togglefullscreen,"

    # ── Special Tag (scratchpad overlay, formerly special workspace) ──
    "SUPER,F12,toggle_special_tag,"
    "SUPER+SHIFT,F12,tag_special_tag,"

    # ── Media Keys ──────────────────────────────────────────────────
    "NONE,XF86AudioRaiseVolume,spawn_shell,wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
    "NONE,XF86AudioLowerVolume,spawn_shell,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
    "NONE,XF86AudioMute,spawn_shell,wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
    "NONE,XF86AudioMicMute,spawn_shell,wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
    # XF86AudioPlay and XF86AudioPause resolve to the same key in mango (the
    # single play/pause media key), so only one binding is declared; a second
    # would be reported as a binding conflict and fail the config check.
    "NONE,XF86AudioPlay,spawn,playerctl play-pause"
    "NONE,XF86AudioNext,spawn,playerctl next"
    "NONE,XF86AudioPrev,spawn,playerctl previous"
    "NONE,XF86AudioStop,spawn,playerctl stop"
    "NONE,XF86MonBrightnessUp,spawn,brightnessctl set +5%"
    "NONE,XF86MonBrightnessDown,spawn,brightnessctl set 5%-"
    "NONE,XF86Calculator,spawn,foot -e ${pkgs.python3}/bin/python3 -ic \"from math import *; print(eval(input('> ')))\""
    "NONE,XF86Sleep,spawn_shell,systemctl suspend"
    "NONE,XF86PowerOff,spawn,wlogout"

    # ── Application Launchers ───────────────────────────────────────
    "SUPER,c,spawn,foot -e opencode"
    "SUPER,x,spawn,foot -e agy"
    "SUPER,n,spawn,foot -e nnn"
    "SUPER,i,spawn,foot -e htop"
    "SUPER,p,spawn,pavucontrol"
    "SUPER,u,spawn,foot -e nvim"
    "SUPER,y,spawn,foot -e lazygit"
    "SUPER,o,spawn,obsidian"
    "SUPER+ALT,k,spawn,keepassxc"
    "SUPER+ALT,f,spawn,foot -e lf"

    # ── Gaming ──────────────────────────────────────────────────────
    "SUPER+SHIFT,g,spawn,gamescope -w 1920 -h 1080 -r 120 -- steam"
    "SUPER+ALT,h,spawn,heroic"
    "SUPER+SHIFT,b,spawn,bottles"
    "SUPER+ALT,l,spawn,lutris"

    # ── System ──────────────────────────────────────────────────────
    "SUPER+SHIFT,q,spawn,wlogout"
    "SUPER+CTRL+SHIFT,r,spawn_shell,sudo nixos-rebuild switch --flake ~/.config/nix-config#desktop"
    "SUPER+SHIFT,u,spawn,foot -e tundra rbu"
  ];
in {
  # circle_layout drives SUPER+SHIFT+R (switch_layout): dwindle ↔ master-stack.
  wayland.windowManager.mango.settings = {
    circle_layout = "dwindle,tile";
    bind = bindings;
  };
}