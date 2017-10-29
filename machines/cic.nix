{ config, lib, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ../profiles/default.nix
    ../profiles/nas.nix
  ];

  boot.initrd.availableKernelModules = [ "ahci" "ohci_pci" "ehci_pci" "pata_atiixp" "usb_storage" "usbhid" "sd_mod" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  boot.supportedFilesystems = [ "zfs" ];
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/disk/by-id/usb-SanDisk_Ultra_Fit_4C530001210615122264-0:0";

  fileSystems."/" =
    { device = "zones/nixos";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    { device = "zones/nix";
      fsType = "zfs";
    };

  fileSystems."/boot" =
  { device = "/dev/disk/by-uuid/9634-48F6";
    fsType = "vfat";
  };

  fileSystems."/media" =
  { device = "zones/media";
    fsType = "zfs";
  };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/aa8b39de-2005-4668-bdb2-507fbe3391ce"; }
    ];

  nix.maxJobs = lib.mkDefault 2;
  powerManagement.cpuFreqGovernor = "ondemand";

  networking.hostId = "567f8775";
  networking.hostName = "cic";

  networking.interfaces.enp3s0.ip4 = [ { address = "192.168.178.2"; prefixLength = 24; } ];
  networking.defaultGateway = "192.168.178.1";
  networking.nameservers = [ "192.168.178.1" ];
}
