{ config, pkgs, ... }:

{
  imports = [ ./desktop.nix ];

  environment.systemPackages = with pkgs; [
    libreoffice-fresh
    signal-desktop
    steam

# meson cross-compilation?

#
# wine winetricks
# Uncommented due to qt failure
  ];
}
