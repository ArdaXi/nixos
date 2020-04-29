{ config, pkgs, ... }:

{
  imports = [ ./desktop.nix ];

  environment.systemPackages = with pkgs; [
    libreoffice-fresh
    signal-desktop
    steam
    rustracer

# meson cross-compilation?

#
# wine winetricks
# Uncommented due to qt failure
  ];
}
