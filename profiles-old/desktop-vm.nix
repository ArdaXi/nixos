{ config, ... }:

{
  imports = [
    ./default.nix
    ./desktop.nix
    <nixpkgs/nixos/modules/virtualisation/qemu-vm.nix>
  ];
}
