{ config, lib, pkgs, ... }:

{
  # Extended Gaming Tools for Omarchy-like experience (Home Manager user-level)

  # Heroic Games Launcher (Epic Games, GOG, Amazon Prime)
  programs.heroic = {
    enable = true;
  };

  # Bottles (Windows apps/games via Wine)
  programs.bottles = {
    enable = true;
  };

  # Lutris (Game manager)
  programs.lutris = {
    enable = true;
  };

  # Steam - enhanced (already enabled in configuration.nix)
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    gamescopeSession.enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin pkgs.proton-ge-custom ];
  };

  # Prism Launcher (Minecraft launcher)
  programs.prismlauncher = {
    enable = true;
  };

  # Proton-GE + Proton-GE-Custom + ProtonUp-Qt
  home.packages = with pkgs; [
    proton-ge-bin
    proton-ge-custom
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

  # Game controllers
  programs.input-remapper = {
    enable = true;
  };

  # Gaming-specific environment variables (home-manager level)
  home.sessionVariables = {
    # Proton
    PROTON_USE_SYSTEM_VULKAN = "1";
    PROTON_NO_ESYNC = "0";
    PROTON_NO_FSYNC = "0";

    # DXVK
    DXVK_ASYNC = "1";
    DXVK_STATE_CACHE = "1";
    DXVK_STATE_CACHE_PATH = "$HOME/.cache/dxvk";

    # VKD3D
    VKD3D_CONFIG = "dxr11,multi_queue";

    # MangoHUD
    MANGOHUD = "1";
    MANGOHUD_CONFIG = "gpu_temp,gpu_load,cpu_temp,cpu_load,ram,vram,fps,frame_timing=1";

    # GameMode
    GAMEMODE = "1";

    # Steam
    STEAM_COMPAT_CLIENT_INSTALL_PATH = "$HOME/.steam/steam";

    # AMD GPU
    RADV_PERFTEST = "aco,rt,sam,nggc";
    AMD_DEBUG = "useaco,nowc";
  };

  # Systemd user services for gaming
  systemd.user.services.gamemode = {
    description = "GameMode daemon";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "dbus";
      BusName = "org.freedesktop.GameMode";
      ExecStart = "${pkgs.gamemode}/bin/gamemoded";
    };
  };
}