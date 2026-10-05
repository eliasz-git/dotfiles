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
  wayland.windowManager.hyprland.settings.monitor = [
    # Philips 27E2N2100, centre. Native 1920x1080; 120Hz is the highest mode it
    # reports, so keep it.
    "HDMI-A-1,1920x1080@120,0x0,1"

    # Acer KA220HQ, left of the Philips. Native 1920x1080 at 60Hz, the only
    # 1080p mode it reports. -1920x0 puts the Acer's right edge on the Philips'
    # left edge, so the two sit flush with no gap.
    "HDMI-A-2,1920x1080@60,-1920x0,1"
  ];
}
