{ config, lib, pkgs, ... }:

{
  imports = [
    ../users/ardaxi
    ../profiles/desktop
  ];

  hardware = {
    enableRedistributableFirmware = true;
    opengl.enable = true;
  };

  boot = {
    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "ahci" "thunderbolt" "usb_storage" "usbhid" "sd_mod" ];

    };
    kernelModules = [ "kvm-amd" ];

    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };

    supportedFilesystems = [ "zfs" ];
    tmp.useTmpfs = true;

    binfmt.emulatedSystems = [
      "armv6l-linux"
      "armv7l-linux"
      "aarch64-linux"
    ];
  };

  fileSystems = {
    "/" = {
      device = "tank/system/root";
      fsType = "zfs";
    };
    "/nix" = {
      device = "tank/local/nix";
      fsType = "zfs";
    };
    "/home" = {
      device = "tank/user/home";
      fsType = "zfs";
    };
    "/boot" = {
      device = "/dev/disk/by-partuuid/1b7400eb-b8e1-4ac2-b65c-b8ec78047526";
      fsType = "vfat";
    };
  };

  swapDevices = [{
    device = "/dev/disk/by-partuuid/fa07eb19-d4ac-4b0b-b13c-76dc8160eac8";
    randomEncryption.enable = true;
  }];

  nix = {
    maxJobs = 16;
    buildCores = 16;
  };

  networking = {
    hostId = "98597f2c";
    hostName = "raven";
    useDHCP = false;
  };

  systemd.network = {
    networks."10-main" = {
      name = "enp16s0";
      address = [ "192.168.178.4/24" "2a10:3781:19df:3::4/64" ];
      gateway = [ "192.168.178.1" ];
      dns = [ "192.168.178.1" ];
    };
  };

  system.stateVersion = "25.05";

  hardware.cpu.amd.updateMicrocode = true;
}
