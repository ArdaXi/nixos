# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let hostName = "${builtins.readFile ./hostname}";
in
rec {
  imports = [ 
      ./hardware-configuration.nix
      ./configuration-common.nix
      (./machines + "/${hostName}.nix")
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sdb";

  boot.supportedFilesystems = [ "zfs" ];

  networking.hostName = "raven"; # Define your hostname.
  networking.hostId = "85703e9c";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable the X11 windowing system.

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.03";

  services.vmwareGuest.enable = true;

}
