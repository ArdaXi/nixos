# This file contains all packages that are only needed for my current project, and should be reconsidered on switching.
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    remmina
  ];

  services.mongodb.enable = true;
}
