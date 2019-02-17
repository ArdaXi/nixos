{ config, ... }:

{
  imports = [
    ./default.nix
    ./desktop.nix
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-base.nix>
  ];

  isoImage.baseImage = "nixos-ardaxi";
}
