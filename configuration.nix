# This file is an impure recreation of the flake profile currently deployed
# based on the system's hostname. The purpose is so tools which do not yet have
# flake support (such as `nixos-options`) work as expected.
{ lib, ... }:
let
  inherit (builtins) attrNames readDir pathExists;

  hostname = lib.fileContents /etc/hostname;
  host = "/etc/nixos/hosts/${hostname}.nix";
  config = 
    if (pathExists host) then
      [ host ]
    else
      [ /etc/nixos/hosts/NixOS.nix ];
in
{
  imports = (import ./modules/list.nix) ++ [
    "${
      builtins.fetchTarball
        "https://github.com/rycee/home-manager/archive/master.tar.gz"
    }/nixos"
    /etc/nixos/profiles/core.nix
  ] ++ config;

  networking.hostName = hostname;
  nix.nixPath = [
    "nixpkgs=${<nixpkgs>}"
    "nixos-config=/etc/nixos/configuration.nix"
    "nixpkgs-overlays=/etc/nixos/overlays"
  ];

  nixpkgs.overlays =
    let
      overlays = map
        (name: import (./overlays + "/${name}"))
        (attrNames (readDir ./overlays));
    in
    overlays;
}
