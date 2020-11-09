{ config, lib, ... }:

{
  imports = [
    ./default.nix
    ./desktop.nix
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-base.nix>
  ];

  isoImage.isoBaseName = "nixos-ardaxi";

  networking.wireless.enable = lib.mkForce false;

  services.openssh.permitRootLogin = lib.mkForce "no";
}
