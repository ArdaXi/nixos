# This file contains all packages that are only needed for my current project, and should be reconsidered on switching.
{ config, pkgs, ... }:

let
  mypkgs = pkgs // import ../pkgs;
in
{
  environment.systemPackages = with pkgs; [
    kubernetes
    awscli
    packer
    terraform
  ];

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  users.extraUsers.ardaxi.extraGroups = [ "docker" ];

  virtualisation.virtualbox.host.enable = true;
}
