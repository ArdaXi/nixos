{ config, lib, ... }:

{
  imports = [
    ./default.nix
    ./desktop.nix
    <nixpkgs/nixos/modules/installer/netboot/netboot-base.nix>
  ];

  networking.wireless.enable = lib.mkForce false;

  services.openssh.permitRootLogin = lib.mkForce "no";
}
