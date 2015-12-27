{ config, lib, pkgs, ... }:

with lib;

{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/iso-image.nix>
    <nixpkgs/nixos/modules/profiles/all-hardware.nix>
    <nixpkgs/nixos/modules/profiles/clone-config.nix>
    ../profiles/default.nix
  ];

  isoImage = {
    isoName = "${config.isoImage.isoBaseName}-${config.system.nixosVersion}-${pkgs.stdenv.system}.iso";
    volumeID = substring 0 11 "NIXOS_ISO";
    makeEfiBootable = true;
    makeUsbBootable = true;
  };

  boot.loader.grub.memtest86.enable = true;

  # Allow password-less root logins
  users.extraUsers.root.initialHashedPassword = "";

  networking.hostId = "85703e9c";
  networking.hostName = "nixos";
}
