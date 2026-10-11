{ config, lib, pkgs, ... }:

let
  palette = config.tundra.palette;
  # Mango colors are 0xRRGGBBAA; the Tundra palette is #RRGGBB, so add a
  # fixed alpha byte on the end.
  hex = color: "0x${lib.removePrefix "#" color}ff";
  shadow = color: "0x${lib.removePrefix "#" color}cc";
in
{
  wayland.windowManager.mango.settings = {
    # ── Look & feel ──────────────────────────────────────────────
    border_px = 2;
    border_radius = 8;
    gap_inner_horizontal = 0;
    gap_inner_vertical = 0;
    gap_outer_horizontal = 0;
    gap_outer_vertical = 0;

    border_color = hex palette.surface0;
    focus_color = hex palette.blue;
    root_color = hex palette.base;

    # ── Effects ──────────────────────────────────────────────────
    blur = true;
    blur_optimized = true;
    blur_params = {
      radius = 10;
      num_passes = 2;
    };
    shadows = true;
    shadows_size = 10;
    shadows_blur = 10;
    shadows_color = shadow palette.base;
    shadow_only_floating = true;

    # ── Opacity ──────────────────────────────────────────────────
    focused_opacity = 1.0;
    unfocused_opacity = 0.9;

    # ── Animations ───────────────────────────────────────────────
    # layer_animations stays off (mango default) so menubars/rofi don't
    # animate, mirroring Hyprland where only client windows animated.
    animations = true;
    animation_type_open = "slide";
    animation_type_close = "slide";
    animation_fade_in = true;
    animation_fade_out = true;
    animation_duration_move = 500;
    animation_duration_open = 400;
    animation_duration_tag = 600;
    animation_duration_close = 300;
    animation_duration_focus = 400;
    # The Hyprland myBezier curve, applied to every animation type.
    animation_curve = {
      move = "0.05,0.9,0.1,1.05";
      open = "0.05,0.9,0.1,1.05";
      tag = "0.05,0.9,0.1,1.05";
      close = "0.05,0.9,0.1,1.05";
      focus = "0.05,0.9,0.1,1.05";
      opacity_fade_in = "0.05,0.9,0.1,1.05";
      opacity_fade_out = "0.05,0.9,0.1,1.05";
    };

    # ── Misc ─────────────────────────────────────────────────────
    # Cursor behaviour: always warp to the focus target (Hyprland's
    # cursor.no_warps = false), ignore fractional XWayland scaling
    # (Hyprland's xwayland.force_zero_scaling = true), no tearing.
    warp_cursor = true;
    xwayland_ignore_scale = true;
    allow_tearing = false;
    cursor_size = 24;
    cursor_theme = "Bibata-Modern-Classic";

    # ── Window rules ─────────────────────────────────────────────
    # Floating apps
    # NOTE: mango has no ==window-is-fullscreen== match criterion, so the
    # Hyprland rule "opacity 1 on fullscreen for zen-beta" cannot be carried
    # over; zen stays at 0.92 even when fullscreen. Known deviation.
    window_rule = [
      "is_floating:1,app_id:^(pavucontrol|blueman-manager|nm-connection-editor|gnome-calculator|org.gnome.Characters)$"
      "is_floating:1,title:^Picture-in-Picture$"
      "is_floating:1,app_id:^steam_app_0$"

      # Per-app opacity
      "focused_opacity:0.85,unfocused_opacity:0.85,app_id:^foot$"
      "focused_opacity:0.88,unfocused_opacity:0.88,app_id:^VSCodium$"
      "focused_opacity:0.92,unfocused_opacity:0.92,app_id:^zen-beta$"
      "focused_opacity:0.85,unfocused_opacity:0.85,app_id:^thunar$"
      "focused_opacity:0.88,unfocused_opacity:0.88,app_id:^obsidian$"

      # Tag assignments (open on this tag, silently when the tag is unfocused)
      "tags:1,is_tag_silent:1,app_id:^(zen-beta|firefox|chromium)$"
      "tags:2,is_tag_silent:1,app_id:^(code|VSCodium|vscodium)$"
      "tags:3,is_tag_silent:1,app_id:^(foot|ghostty|alacritty|kitty)$"
      "tags:4,is_tag_silent:1,app_id:^(discord|signal|telegram|beeper)$"
      "tags:5,is_tag_silent:1,app_id:^(obsidian|thunar|libreoffice)$"
      "tags:6,is_tag_silent:1,app_id:^(spotify|mpv|iina|vlc)$"
      "tags:7,is_tag_silent:1,app_id:^(steam|heroic|bottles|lutris|prismlauncher)$"
      "tags:8,is_tag_silent:1,app_id:^(keepassxc|bitwarden|veracrypt)$"
      "tags:9,is_tag_silent:1,app_id:^(virt-manager|UTM|docker|qemu)$"

      # Screensaver: opened by tundra-screensaver.sh on the special overlay
      # (tag 0). is_tag_silent keeps the window from stealing the view or focus
      # when it maps, floating avoids layout in the overlay, and is_fullscreen
      # makes the art fill the screen once the overlay is revealed.
      "tags:0,is_tag_silent:1,is_floating:1,is_fullscreen:1,no_border:1,no_shadow:1,no_radius:1,app_id:^tundra-screensaver$"

      # Size/position rules (floats centre by default in mango)
      "width:800,height:600,app_id:^(pavucontrol|blueman-manager)$"
    ];
  };
}