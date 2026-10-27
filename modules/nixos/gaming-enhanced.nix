{ config, lib, pkgs, ... }:

{
  # Extended Gaming Tools for Omarchy-like experience (Home Manager user-level)

  # Heroic Games Launcher (Epic Games, GOG, Amazon Prime)
  # programs.heroic removed - handled via Home Manager home.packages

  # Bottles (Windows apps/games via Wine) - managed via Home Manager packages
  # programs.bottles removed - see home.packages instead

  # Lutris (Game manager) - managed via Home Manager home.packages
  # programs.lutris removed - see home.packages below

  # Steam is enabled once, system-wide, in configuration.nix — not repeated here.
  # (programs.steam is a NixOS option anyway; redefining it at this
  # Home-Manager level is what broke evaluation.)

  # Prism Launcher (Minecraft launcher)
  programs.prismlauncher = {
    enable = true;
  };

  # Proton-GE-bin comes from configuration.nix's programs.steam.extraCompatPackages
  # already — not duplicated here. proton-ge-custom isn't a real nixpkgs package
  # (that was the actual break); protonup-qt covers "get me another GE build".
  home.packages = with pkgs; [
    protonup-qt
    # Wine-GE is managed via protonup-qt
    # DXVK, VKD3D latest
    dxvk
    vkd3d
    # GameMode, MangoHUD, Gamescope
    gamemode
    mangohud
    gamescope
    # LACT for AMD GPU control
    lact
    # Steam TUI
    steam-tui
    # OpenRGB for RGB control
    openrgb
    # CoreCtrl for AMD GPU control alternative
    corectrl
  ];

  # Game controller remapping: services.input-remapper.enable lives in
  # configuration.nix (it needs uinput/udev access, so it's a system service,
  # not a Home-Manager option — programs.input-remapper doesn't exist in HM,
  # which is what broke evaluation).

  # Game-specific compatibility and driver flags intentionally stay out of the
  # global session. Configure them in Steam's per-game launch options instead.

  # No hand-rolled gamemode systemd unit here: programs.gamemode.enable in
  # configuration.nix already ships gamemoded's own D-Bus-activated service.
  # A second unit claiming the same "org.freedesktop.GameMode" bus name would
  # just race the real one for ownership.
}
