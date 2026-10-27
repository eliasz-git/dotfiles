{ config, lib, ... }:
{
  # Shared defaults for the headless homelab machines. Hardware, storage,
  # role-specific services, and host identity remain in each host file.
  time.timeZone = lib.mkDefault "America/New_York";
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  console.keyMap = lib.mkDefault "us";

  programs.zsh.enable = true;

  services.tailscale.enable = true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      KbdInteractiveAuthentication = false;
    };
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
  };
  boot.kernel.sysctl."vm.swappiness" = lib.mkDefault 10;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Keep the OS journal from consuming a small system disk during a container
  # failure. Application logs have their own Compose rotation policy.
  services.journald.settings.Journal = {
    SystemMaxUse = "1G";
    RuntimeMaxUse = "256M";
  };
}
