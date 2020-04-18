{ config, pkgs, ... }:

{
  imports = [ ./desktop.nix ];

  environment.systemPackages = with pkgs; [
    libreoffice-fresh
    signal-desktop
    steam
# meson cross-compilation?

# rustracer
# Build failure
#
# wine winetricks
# Uncommented due to qt failure
  ];
}
