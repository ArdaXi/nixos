{ config, lib, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ../profiles/default.nix
    ../profiles/nas.nix
  ];

  system.stateVersion = "18.03";

  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "ehci_pci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.supportedFilesystems = [ "zfs" ];

  boot.loader = {
      grub.enable = false;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
  };

  boot.tmpOnTmpfs = true;

  fileSystems."/" =
    { device = "zones/nixos";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    { device = "zones/nix";
      fsType = "zfs";
    };

  fileSystems."/boot" =
  { device = "/dev/disk/by-uuid/B081-027E";
    fsType = "vfat";
  };

  fileSystems."/media" =
  { device = "zones/media";
    fsType = "zfs";
  };

  swapDevices =
    [ { device = "/dev/disk/by-partuuid/d6c13608-1d4f-4b6b-a64b-e709ba7208d8"; }
    ];

  nix.maxJobs = 6;
  powerManagement.cpuFreqGovernor = "ondemand";

  networking = {
    hostId = "567f8775";
    hostName = "cic";
    nameservers = [ "8.8.4.4" "8.8.8.8" ];
  };
}
