{ config, lib, pkgs, ... }:

with lib;
rec {
  imports = [
    ./profiles/default.nix
  ];

  nixpkgs.config.allowUnfree = true;

  users.extraUsers.ardaxi = {
    name = "ardaxi";
    group = "ardaxi";
    extraGroups = [
      "users"
      "wheel"
      "networkmanager"
      "audio"
    ];
    uid = 1000;
    home = "/home/ardaxi";
    createHome = true;
    shell = "/run/current-system/sw/bin/zsh";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC9L+dgqEWlz1HCAFvOo2WMcxXUCVZjEENrSCHEHdGKx ardaxi@hiro"
    ];
  };
  users.extraGroups.ardaxi.gid = 1000;

  programs.zsh.enable = true;
}
