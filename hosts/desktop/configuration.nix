{ config, pkgs, lib, hermes-agent, ... }:

# Desktop — Ryzen 5 5600 + AMD Radeon GPU, Mango (Wayland), Steam.
# Apply on the machine:  sudo nixos-rebuild switch --flake ~/.config/dotfiles#desktop
let
  # Local package for Ghostty terminfo (xterm-ghostty)
  # Ghostty's terminfo is not in nixpkgs for Linux, so we compile it from source
  ghostty-terminfo = import ../../pkgs/ghostty-terminfo {
    inherit lib;
    inherit (pkgs) stdenv ncurses writeTextFile;
  };
in {
    imports = [
      ./hardware-configuration.nix
      ../../modules/system/themes.nix
      ../../modules/nixos/themes.nix
      ../../modules/nixos/sddm-theme.nix
      ../../modules/system/nix-settings.nix
    ];

  # System-level theme registry and optional Swaylock fallback, plus the
  # `tundra-theme` binary) is gated behind this flag in modules/system/themes.nix
  # and modules/nixos/themes.nix — without it those modules are dead code even
  # though they're imported. home.nix sets the matching HM-level flag.
  tundra.enable = true;
  tundra.theme = "everforest-blue";

  # ── BOOT ──────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  # Zen 3 P-state driver. Falls back to acpi-cpufreq on its own if the BIOS
  # has CPPC turned off, so it is safe either way.
  boot.kernelParams = [
    "amd_pstate=active"

    # ── AMD GPU (RX 6600 / Navi 23) stability mitigations ──
    # BACO / runtime PM is a frequent RDNA2 hang source with VRR + multi-monitor.
    "amdgpu.runpm=0"
    # ASPM link power-saving on the GPU PCIe link — another hang trigger.
    "amdgpu.aspm=0"
    "pcie_aspm=off"
    # Attempt GPU reset/recovery instead of escalating to a full panic.
    "amdgpu.gpu_recovery=1"
    # Give display commits highest priority — helps with HDMI-A-1 VRR atomic commit hangs.
    "amdgpu.disp_priority=2"
    # Mask panel self-refresh — one RDNA2 user reported it prevents VRAM-stuck hangs at high refresh.
    "amdgpu.dcdebugmask=0x10"
    # Mode1 GPU reset is more reliable on RDNA2 than the default auto.
    "amdgpu.reset_method=2"
    # kdump capture target so a vmcore is written after a real kernel panic.
    "crashkernel=256M"

    # ── Diagnostics (verbose DRM logging) ──
    # amdgpu.dcdebug is NOT a valid kernel param (ignored at boot). drm.debug=0x14
    # enables DPM + driver debug output; displayed in journal during hangs.
    "drm.debug=0x14"
  ];

  # ── NETWORK ───────────────────────────────────────────────────
  networking.hostName = "desktop";
  networking.networkmanager.enable = true;

  # Wake-on-LAN. NixOS ships this as a udev .link (WakeOnLan=magic) applied at
  # device enumeration, so NetworkManager taking the interface does not clobber
  # it. BIOS ErP/Deep Sleep must be Disabled or the NIC loses standby power.
  networking.interfaces.enp4s0.wakeOnLan = {
    enable = true;
    policy = [ "magic" ];
  };

  # Tailnet transport: Moonlight from off-LAN without port forwarding, and the
  # path to `wakeonlan` on mini for remote wake. Run `sudo tailscale up` once
  # after the rebuild.
  services.tailscale.enable = true;

  # ── LOCALE ────────────────────────────────────────────────────
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  # ── USER ──────────────────────────────────────────────────────
  users.users.elias = {
    isNormalUser = true;
    description = "elias";
    extraGroups = [ "wheel" "networkmanager" "video" "render" "input" "pcscd" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFa0mPA2Wbc4JsyzHxjgBrQubUYAq0qXa/ZCyl4TNMj3 tundra-node@github"
    ];
  };
  programs.zsh.enable = true;

  # Puts ~/.local/bin on PATH through /etc/profile, which the SDDM session
  # wrapper sources, so Mango and everything it spawns can run the tundra-*
  # scripts that home.nix links there (bindings call tundra-screensaver by
  # name). The zsh initContent export only reaches interactive shells.
  environment.localBinInPath = true;

  # Provides pkgs.dconf via services.dbus.packages so the `ca.desrt.dconf`
  # D-Bus activation service exists for Home Manager's dconfSettings step
  # (gtk.enable in home.nix). It stopped leaking in transitively after the
  # 2026-10-10 nixpkgs bump.
  programs.dconf.enable = true;

  # ── GRAPHICS (AMD, Mesa/RADV) ─────────────────────────────────
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Steam / Proton need 32-bit GL + Vulkan
  };
  hardware.amdgpu.initrd.enable = true; # load amdgpu early so the console isn't stuck at low-res
  hardware.enableRedistributableFirmware = true; # amdgpu firmware blobs
  services.lact.enable = true; # AMD GPU fan/clock/power control (replaces radeon-profile)

  # ── DESKTOP: MANGO ──────────────────────────────────────────
  # Compositor + portals live here; the config lives in home.nix. The mango
  # flake module (imported in flake.nix) configures xdg-portal (wlr + gtk),
  # xwayland and polkit, and registers the Mango session for SDDM.
  programs.mango.enable = true;
  services.flatpak.enable = true;

  # Graphical SDDM login: a dark, image-capable surface fits the Omarchy/Tundra
  # visual language much better than a terminal greeter with ANSI colors.
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    autoNumlock = true;
  };

  # Sunshine runs as a user service on graphical-session.target, so after a
  # reboot it does not exist until a session is up. Without auto-login a remote
  # wake would land on the greeter with no way in. swayidle locks at 300s and
  # before suspend (hosts/desktop/home.nix), so the unlocked window is brief.
  services.displayManager.autoLogin = {
    enable = true;
    user = "elias";
  };
  services.seatd.enable = true;
  services.displayManager.defaultSession = "mango";

  environment.sessionVariables.NIXOS_OZONE_WL = "1"; # Electron/Chromium apps on Wayland

  # ── GAMING ────────────────────────────────────────────────────
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    gamescopeSession.enable = true;
  };
  programs.gamemode.enable = true;
  programs.gamescope.enable = true;

  # ── REMOTE DESKTOP ────────────────────────────────────────────
  # Sunshine (Moonlight-compatible host): AMD AMF/VAAPI encode on the RX 6600,
  # capture through the Mango compositor's wlr-screencast via PipeWire.
  # capSysAdmin installs a setuid-cap wrapper for direct KMS capture and
  # cursor compositing; without it capture works but cursor handling is flaky.
  # Pair at https://<host>:47989 (self-signed), then add the host in Moonlight.
  services.sunshine = {
    enable = true;
    capSysAdmin = true;
    openFirewall = true;
    autoStart = true;
  };

  # Controller/keyboard remapping. Udev rules for hotplug are left off (upstream
  # default): https://github.com/sezanzeb/input-remapper/issues/140 — devices
  # plugged in before the service starts still work; hotplugged ones need
  # `sudo systemctl restart input-remapper` until that's fixed.
  services.input-remapper.enable = true;

  # Virtual webcam support
  # kvm-amd (from hardware-configuration.nix) + v4l2loopback + efi_pstore + netconsole.
  # efi_pstore gives a persistent pstore backend so crash dumps survive reboot.
  # netconsole streams kernel log over UDP *before* the CPU dies — essential for
  # capturing hard GPU hangs where the journal can't flush (pstore won't help
  # without a real panic). Uncomment and set your remote syslog host below:
  #   "netconsole=6666@<your-ip>/<your-mac>@<remote-ip>/<remote-mac>"
  boot.kernelModules = [ "kvm-amd" "v4l2loopback" "efi_pstore" "netconsole" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=10 card_label="VirtualCam" exclusive_caps=1
  '';

  # ── SOUND ─────────────────────────────────────────────────────
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true; # 32-bit games / Wine
    pulse.enable = true;
  };

  # ── BLUETOOTH ─────────────────────────────────────────────────
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # ── POWER ─────────────────────────────────────────────────────
  # Desktop: no TLP (laptop-oriented). power-profiles-daemon is DISABLED here
  # because it conflicts with LACT on amdgpu_dpm (both try to own GPU power
  # state, which can race the GPU into a hang). LACT is the GPU-specific
  # manager and is left enabled above (services.lact.enable = true).
  services.power-profiles-daemon.enable = false;
  zramSwap.enable = true;

  # ── INPUT ─────────────────────────────────────────────────────
  services.libinput.enable = true;

  # YubiKey: let the logged-in user access the device directly so KeePassXC
  # can use it for challenge-response (and FIDO2) without root. The uaccess
  # tag makes systemd-logind grant the active session rw on the device node.
  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="usb", ATTRS{idVendor}=="1050", TAG+="uaccess"
  '';

  # PC/SC smart card daemon — required for KeePassXC to talk to the YubiKey
  # over CCID (challenge-response unlock).
  services.pcscd.enable = true;

  # ── SERVICES ──────────────────────────────────────────────────
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Desktop Syncthing service for vault and selected workstation folders.
  services.syncthing = {
    enable = true;
    user = "elias";
    dataDir = "/home/elias/.config/syncthing";
    configDir = "/home/elias/.config/syncthing";
    openDefaultPorts = true;
    guiAddress = "127.0.0.1:8384";
    overrideDevices = false;
    overrideFolders = true;
    settings = {
      folders = {
        eagle-scout = {
          id = "eagle-scout";
          label = "Eagle Scout";
          path = "/home/elias/Documents/Career/Eagle Scout";
          type = "sendreceive";
          devices = [ ];
          versioning = {
            type = "staggered";
            params = {
              maxAge = "31536000";
            };
          };
        };
        school-docs = {
          id = "school-docs";
          label = "School";
          path = "/home/elias/Documents/School";
          type = "sendreceive";
          devices = [ ];
          versioning = {
            type = "staggered";
            params = {
              maxAge = "31536000";
            };
          };
        };
        desktop-sync = {
          id = "desktop-sync";
          label = "Desktop";
          path = "/home/elias/Desktop";
          type = "sendreceive";
          devices = [ ];
          versioning = {
            type = "staggered";
            params = {
              maxAge = "31536000";
            };
          };
        };
        backups-sync = {
          id = "backups-sync";
          label = "Backups";
          path = "/home/elias/Backups";
          type = "sendreceive";
          devices = [ ];
          versioning = {
            type = "staggered";
            params = {
              maxAge = "31536000";
            };
          };
        };
        genealogy-sync = {
          id = "genealogy-sync";
          label = "Genealogy";
          path = "/home/elias/Documents/Genealogy";
          type = "sendreceive";
          devices = [ ];
          versioning = {
            type = "staggered";
            params = {
              maxAge = "31536000";
            };
          };
        };
      };
    };
  };
  systemd.user.services.syncthing.enable = lib.mkForce false;

  # ── FONTS & PACKAGES ──────────────────────────────────────────
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.victor-mono
  ];

  environment.systemPackages = with pkgs; [
    git curl wget pciutils smartmontools usbutils
    wakeonlan # magic packets to mini/other hosts; MAC lives in /sys/class/net/enp4s0/address
    moonlight-qt # client, for testing the loopback from this machine
    android-tools # Android SDK platform tools (adb/fastboot)
    # Hermes Agent (Nous Research). Portable state (skills/memory/config)
    # syncs Mac <-> desktop via Syncthing; state.db stays local per machine.
    hermes-agent.packages.x86_64-linux.default
    bemenu # menu program for xdg-desktop-portal-wlr screen/window picker (OBS screen capture)
    ghostty-terminfo # terminfo for xterm-ghostty (Ghostty terminal)
    # ── Graphics (ensure Mesa/RADV + Vulkan loader are present for Proton) ──
    mesa          # OpenGL + Vulkan RADV driver for AMD GPUs
    vulkan-loader # Vulkan ICD loader
    # ── Diagnostics ──
    mesa-demos   # glxinfo — verify OpenGL renderer/hardware acceleration
    vulkan-tools # vulkaninfo — verify Vulkan device + RADV driver
    lm_sensors   # sensors — read GPU/CPU/mobo temps under load
  ];

  # ── SECOND SSD: Steam Games Library ─────────────────────────────
  # nvme1n1p2 — the data/games NVMe, now a native ext4 filesystem so Steam and
  # Proton get real POSIX semantics (case-sensitivity, symlinks, permissions).
  # The old ntfs3 mount kept failing whenever Windows left the volume dirty,
  # which silently broke the boot-time mount and hid the library from Steam.
  fileSystems."/Games" = {
    device = "/dev/disk/by-uuid/4ac39be5-bc86-45d6-9bab-fb0276adbe7e";
    fsType = "ext4";
    # nofail: a temporarily absent data drive must never block boot. noatime
    # matches the other data mounts and trims needless metadata writes.
    options = [ "nofail" "noatime" ];
  };

  # Monitor both internal NVMe drives for failing sectors and controller health.
  services.smartd = {
    enable = true;
    autodetect = true;
    notifications.wall.enable = true;
    notifications.mail.enable = false;
  };

  # Capture crash dumps when Steam/game/compositor segfaults — essential for
  # diagnosing hard GPU hangs where the journal can't flush.
  systemd.coredump.enable = true;

  # ── NIX ───────────────────────────────────────────────────────
  system.stateVersion = "26.05";
}
