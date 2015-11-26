{ config, pkgs, ... }:

{
  imports = [
    ../profiles/desktop.nix
    ../profiles/project.nix
  ];

  networking.hostId = "85703e9c";
}
