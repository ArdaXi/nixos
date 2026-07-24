{ config, lib, pkgs, ... }:

{
  imports = [
    ../users/ardaxi
    ../profiles/desktop
  ];

  hardware = {
    enableRedistributableFirmware = true;
    opengl.enable = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  services.udev.extraRules = ''
    SYMLINK=="dri/by-path/pci-0000:7b:00.0-card", SYMLINK+="dri/igpu1"
  '';

  services.physlock.enable = lib.mkForce false;

  programs.sway.extraSessionCommands = ''
    export WLR_DRM_DEVICES="/dev/dri/igpu1"
  '';

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
    device = "/dev/disk/by-partuuid/fa07eb19-d4ac-4b9b-b13c-76dc8160eac8";
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
    firewall.extraCommands = "iptables -A nixos-fw -s 192.168.178.0/24 -j nixos-fw-accept -i enp16s0";
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

  hardware.firmware = [ (pkgs.writeTextDir "/lib/firmware/hda-jack-retask.fw" ''
    [codec]
    0x10ec0897 0x14629e70 0

    [pincfg]
    0x11 0x4037c040
    0x12 0x411111f0
    0x14 0x01014010
    0x15 0x411111f0
    0x16 0x411111f0
    0x17 0x411111f0
    0x18 0x01014012
    0x19 0x02a19040
    0x1a 0x01014011
    0x1b 0x02214020
    0x1c 0x411111f0
    0x1d 0x4028c66b
    0x1e 0x411111f0
    0x1f 0x411111f0
  '') ];

  services.ratbagd.enable = true;
}
