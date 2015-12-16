{ config, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ../profiles/desktop.nix
    ../profiles/project.nix
  ];

  boot.initrd.availableKernelModules = [ "ahci" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "tank/nixos";
    fsType = "zfs";
  };

  fileSystems."/home" {
    device = "tank/home";
    fsType = "zfs";
  };

  fileSystems."/boot" {
    device = "/dev/disk/by-partuuid/a9669530-a697-4656-98e6-326b5099639b";
    fsType = "vfat";
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/15988b90-6ece-4625-97e1-1b5bffd26734"; }
  ];

  nix.maxJobs = 4;

  environment.systemPackages = with pkgs; [
    cryptsetup
  ];

  networking.hostId = "85703e9c";

  boot.loader.gummiboot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = [ "zfs" ];
}
