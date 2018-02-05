{ config, lib, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ../profiles/default.nix
    ../profiles/nas.nix
  ];

  system.stateVersion = "18.03";

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

  fileSystems."/tahoe" =
  { device = "zones/e025500d-71d1-caa0-d9ec-ecf39f3acc6f";
    fsType = "zfs";
  };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/aa8b39de-2005-4668-bdb2-507fbe3391ce"; }
    ];

  nix.maxJobs = 1;
  nix.daemonNiceLevel = 1;
  powerManagement.cpuFreqGovernor = "ondemand";

  networking = {
    hostId = "567f8775";
    hostName = "cic";
    defaultGateway = "192.168.178.1";
    nameservers = [ "192.168.178.1" ];

    bridges.br0.interfaces = [ "enp2s0" "enp3s0" ];

    interfaces.br0.ip4 = [ { address = "192.168.178.2"; prefixLength = 24; } ];
  };
}
