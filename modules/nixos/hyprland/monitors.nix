{ config, lib, pkgs, ... }:

{
  # Hyprland monitor configuration.
  #
  # Both panels are 16:9 and both EDIDs report 1920x1080@60 as the preferred
  # detailed timing, so every rule below names its resolution explicitly.
  #
  # The previous wildcard ",highrr,auto,1" asked for the highest *refresh rate*
  # rather than the highest resolution. On the Acer the only mode above 60Hz is
  # 1152x864@75, so that won and a 4:3 signal was being stretched across a 16:9
  # panel. Pinning the modes keeps that from recurring; `highres` would also
  # work but leaves the refresh rate implicit, and `preferred` would drop the
  # Philips from 120Hz since its preferred timing is 60Hz.
  #
  # The monitor's own OSD aspect setting is a separate layer and needs no
  # change here: at 1920x1080 the signal already matches the panel, so there is
  # nothing left for it to fit.
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
  wayland.windowManager.hyprland.settings.monitor = [
    # Philips 27E2N2100, centre. Native 1920x1080; 120Hz is the highest mode it
    # reports, so keep it. Scale 1 is the reference for the Acer's scale.
    "HDMI-A-1,1920x1080@120,0x0,1"

    # Acer KA220HQ, left of the Philips. Native 1920x1080 at 60Hz, the only
    # 1080p mode it reports.
    #
    # Scale 1.25 because the Acer is much denser: 102 PPI against the Philips'
    # 82 PPI. At scale 1 a window on the Acer covers about a fifth less area
    # than the same window on the Philips, which reads as "wrong" even when
    # nothing is actually misconfigured. 102/82 = 1.25, so scaling by 1.25 puts
    # one logical pixel at 0.311mm on both panels, within 0.2% of each other.
    #
    # The cost is desktop area: the Acer drops from 1920x1080 to 1536x864
    # logical. If you would rather have the extra space, change 1.25 to 1 and
    # the only cost is that UI is ~20% physically smaller on the Acer.
    #
    # Position is -1536, not -1920. Hyprland places monitors in *logical*
    # space, so at scale 1.25 the Acer's logical width is 1920/1.25 = 1536 and
    # -1536x0 sits it flush against the Philips. Leaving -1920 here would open
    # a 384px dead gap between the two.
    "HDMI-A-2,1920x1080@60,-1536x0,1.25"
  ];

  # Deliberately *not* set here, because none of it helps in SDR:
  #
  #   sdrbrightness / sdrsaturation - these are HDR-mode knobs ("SDR brightness
  #     in HDR mode" per the Hyprland docs) and both panels run plain sRGB with
  #     no HDR output enabled. Verified rather than assumed: setting the Acer to
  #     1.0, 0.75 and 0.5 produced byte-identical mean pixel luminance, so the
  #     value is inert here. Setting it would be a knob that looks meaningful
  #     and does nothing.
  #
  #   bitdepth 10 - both panels are 6-bit + FRC. Requesting 10bit gets the
  #     XRGB2101010 format without the panel actually having 10 bits, and 10bit
  #     output is known to break screen capture in Hyprland.
  #
  #   icc - Hyprland's ICC path is the one thing that would genuinely improve
  #     colour, and it does work in SDR. It needs a measured profile per panel,
  #     which needs a colorimeter. Guessing a profile would be worse than
  #     nothing, so it is left off until there is real measurement.
  #
  # The remaining brightness and contrast difference is a hardware one and is
  # best fixed in the monitors' own OSDs:
  #
  #   - Philips 300 cd/m2 vs Acer 200 cd/m2, so the Acer reads dimmer. Dim the
  #     Philips to roughly two-thirds to meet the Acer, or drop both to about
  #     120 cd/m2 for long sessions (Philips ~40%, Acer ~60%).
  #   - Turn OFF dynamic contrast on both: Philips SmartContrast and Acer ACM.
  #     Both boost the backlight per scene, so the two panels drift apart
  #     constantly and never agree, which is worse than a fixed offset.
  #   - Set both colour temperature to a fixed 6500K/user default rather than
  #     any "warm" or "cool" preset, and leave SmartImage on Standard.
  #   - The Acer is TN with 90/65 degree viewing angles and sits off to the
  #     side, so its colour shifts as you move your head. No software setting
  #     compensates for this; angling the panel more square to your chair is
  #     the only real fix.
}