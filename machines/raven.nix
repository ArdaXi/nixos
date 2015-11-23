{ config, pkgs, ... }:

{
  imports = [
    ../profiles/desktop.nix
    ../profiles/project.nix
  ];
}
