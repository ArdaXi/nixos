{ config, ... }:

{
  imports = [
    ./default.nix
    ./desktop.nix
    <nixpkgs/nixos/modules/virtualisation/virtualbox-image.nix>
  ];

  virtualbox.baseImageSize = 15 * 1024;
}
