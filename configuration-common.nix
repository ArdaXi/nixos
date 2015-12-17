{ config, lib, pkgs, ... }:

with lib;
rec {
  imports = [
    ./profiles/default.nix
  ];
}
