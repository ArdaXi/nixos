# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let hostName = "${builtins.readFile ./hostname}";
in
rec {
  imports = 
  [ 
    (./machines + "/${hostName}.nix")
  ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget

}
