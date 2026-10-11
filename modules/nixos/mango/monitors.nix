{ config, lib, pkgs, ... }:

{
  # Mango monitor configuration.
  #
  # Both panels are 16:9 and both EDIDs report 1920x1080@60 as the preferred
  # detailed timing, so every rule below names its resolution explicitly.
  #
  # Mango's monitor_rule matches by name (a regex); the first rule that
  # matches a monitor wins. Names are anchored with ^ and $ so they match
  # exactly.
  #
  # XWayland note: mango warns against negative monitor coordinates (a known
  # XWayland bug breaks clicks there), so the Acer sits at x:0 and the Philips
  # extends right of it. The alpha (primary) display is the Philips, which is
  # what X11 fullscreen games use for coordinates.
  #
  # Panel reality, from the manufacturers' datasheets:
  #
  #                 Philips 27E2N2100    Acer KA220HQ
  #   panel         IPS                 TN
  #   backlight     W-LED               W-LED
  #   brightness    300 cd/m2           200 cd/m2
  #   contrast      1500:1              600:1
  #   viewing angle 178/178             90/65
  #   colour depth  6-bit + FRC         6-bit + HiFRC
  #   pixel density 82 PPI              102 PPI
  #
  # An IPS and a TN panel cannot be made to look identical, and most of the
  # difference is not reachable from software. What *is* reachable is physical
  # size parity, which is what the Acer's scale below handles.
  # Acer KA220HQ, left. Native 1920x1080 at 60Hz, the only 1080p mode it
  # reports. Scale 1.25 because the Acer is much denser: 102 PPI against the
  # Philips' 82 PPI (102/82 = 1.25 → one logical pixel at 0.311mm on both
  # panels). Position 0,0: mango wants non-negative coordinates for XWayland.
  #
  # The Philips rule deliberately lives in ~/.config/tundra/mango-vrr.conf (a
  # sourced fragment seeded by home.nix), not here, so the VRR toggle can
  # rewrite its vrr field live. The two rules match different monitor names, so
  # there is no first-match ordering conflict between the fragment (parsed
  # after this config, last) and this rule.
  wayland.windowManager.mango.settings.monitor_rule = [
    "name:^HDMI-A-2$,width:1920,height:1080,refresh:60,x:0,y:0,scale:1.25"
  ];

  # Deliberately *not* set here, because none of it helps in SDR:
  #
  #   hdr* - both panels run plain sRGB with no HDR output enabled, and Mango's
  #     HDR needs the vulkan renderer (WLR_RENDERER=vulkan) which is not used.
  #
  #   icc - Mango's ICC path would genuinely improve colour but needs a measured
  #     profile per panel, which needs a colorimeter. Guessing a profile would
  #     be worse than nothing, so it is left off until there is real
  #     measurement.
  #
  # The remaining brightness and contrast difference is a hardware one and is
  # best fixed in the monitors' own OSDs:
  #
  #   - Philips 300 cd/m2 vs Acer 200 cd/m2, so the Acer reads dimmer. Dim the
  #     Philips to roughly two-thirds to meet the Acer, or drop both to about
  #     120 cd/m2 for long sessions.
  #   - Turn OFF dynamic contrast on both (Philips SmartContrast, Acer ACM).
  #   - Set both colour temperatures to a fixed 6500K/user default, and leave
  #     SmartImage on Standard.
  #   - The Acer is TN with 90/65 degree viewing angles and sits off to the
  #     side, so its colour shifts as you move your head; angling the panel
  #     more square to your chair is the only real fix.
}