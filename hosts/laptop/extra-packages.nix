{ config, pkgs, ... }:

{
  # Extra packages for print/export workflow
  environment.systemPackages = with pkgs; [
    imagemagick
    exiftool
    ghostscript
    (python3.withPackages (ps: with ps; [ pillow reportlab pypdf2 ]))
  ];
}
