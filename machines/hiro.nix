{ config, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ../profiles/default.nix
    ../profiles/desktop.nix
    ../profiles/project.nix
  ];

  boot.initrd = {
    availableKernelModules = [ "ahci" ];
    kernelModules = [ "fbcon" ];
    luks.devices = [{
      name = "cypher";
      device = "/dev/disk/by-uuid/460c7199-0d25-47df-834a-c69b34b6f0c0";
    }];
  };

  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "tank/nixos";
    fsType = "zfs";
  };

  fileSystems."/home" = {
    device = "tank/home";
    fsType = "zfs";
  };

  fileSystems."/boot" = {
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
  networking.hostName = "hiro";

  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = [ "zfs" ];
}
