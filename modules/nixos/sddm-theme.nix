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

  sddmWithGreeter = pkgs.kdePackages.sddm.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.makeWrapper ];
    postFixup = (old.postFixup or "") + ''
      makeWrapper $out/bin/sddm-greeter-qt6 $out/bin/sddm-greeter --set SDDM_GREETER_MODE qt6
    '';
  });
in {
  systemd.tmpfiles.rules = [
    "d /var/lib/tundra 0755 root root - -"
  ];

  system.activationScripts.tundra-sddm-theme = ''
    mkdir -p "${themeDir}"
    cp -a ${tundraSddmTheme}/share/sddm/themes/tundra/* "${themeDir}/" 2>/dev/null || true
    ln -sfn ${tundraSddmTheme}/share/sddm/themes/tundra/Main.qml "${themeDir}/Main.qml"
    ln -sfn ${tundraSddmTheme}/share/sddm/themes/tundra/metadata.desktop "${themeDir}/metadata.desktop"
    ln -sfn "${userThemeConf}" "${themeDir}/theme.conf"
  '';

  services.displayManager.sddm.package = lib.mkIf config.services.displayManager.sddm.enable (lib.mkForce sddmWithGreeter);
  services.displayManager.sddm.theme = lib.mkIf config.services.displayManager.sddm.enable themeDir;
}
