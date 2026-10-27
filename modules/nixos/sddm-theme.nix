{ config, lib, pkgs, ... }:

let
  themeDir = "/etc/sddm/themes/tundra";
  userThemeConf = "/home/elias/.config/tundra/sddm/theme.conf";

  tundraSddmTheme = pkgs.stdenv.mkDerivation {
    pname = "tundra-sddm-theme";
    version = "1.0";
    src = ../../themes/sddm/tundra;
    installPhase = ''
      mkdir -p $out/share/sddm/themes/tundra
      cp -r $src/* $out/share/sddm/themes/tundra/
    '';
  };
in {
  systemd.tmpfiles.rules = [
    "d /var/lib/tundra 0755 root root - -"
  ];

  system.activationScripts.tundra-sddm-theme = ''
    mkdir -p "/etc/sddm/themes/breeze"
    # Replace only Main.qml and theme.conf, keep original metadata.desktop
    ln -sfn ${tundraSddmTheme}/share/sddm/themes/tundra/Main.qml "/etc/sddm/themes/breeze/Main.qml"
    ln -sfn "${userThemeConf}" "/etc/sddm/themes/breeze/theme.conf"
    # Copy assets
    cp -a ${tundraSddmTheme}/share/sddm/themes/tundra/* "/etc/sddm/themes/breeze/" 2>/dev/null || true
  '';

  services.displayManager.sddm.theme = lib.mkIf config.services.displayManager.sddm.enable "breeze";
}
