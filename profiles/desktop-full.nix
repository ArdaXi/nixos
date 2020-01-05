{ config, pkgs, ... }:

{
  imports = [ ./desktop.nix ];

  environment.systemPackages = with pkgs; [
    libreoffice
    signal-desktop
    zoom-us
    steam
# meson cross-compilation?

# rustracer
# Build failure
#
# wine winetricks
# Uncommented due to qt failure
  ];
}
