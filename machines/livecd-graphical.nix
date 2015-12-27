{ config, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/iso-image.nix>
    <nixpkgs/nixos/modules/profiles/all-hardware.nix>
    <nixpkgs/nixos/modules/profiles/clone-config.nix>
    ../profiles/default.nix
    ../profiles/desktop.nix
  ];

  networking.hostId = "85703e9c";
  networking.hostName = "nixos";
}
