# This file contains all packages that are only needed for my current project, and should be reconsidered on switching.
{ config, pkgs, ... }:

{
  imports = [ ./desktop.nix ];

  environment.systemPackages = with pkgs; [
    steam libreoffice wine winetricks
    riot-desktop signal-desktop rustracer
  ];
}
