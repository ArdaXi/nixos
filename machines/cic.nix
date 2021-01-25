{ config, lib, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ../profiles/default.nix
    ../profiles/default-programs.nix
    ../profiles/nas/default.nix
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

  fileSystems."/tahoe" =
  { device = "zones/e025500d-71d1-caa0-d9ec-ecf39f3acc6f";
    fsType = "zfs";
  };

  fileSystems."${config.services.ipfs.dataDir}" = lib.mkIf config.services.ipfs.enable {
    device = "zones/ipfs";
    fsType = "zfs";
  };

  swapDevices =
    [ { device = "/dev/disk/by-partuuid/d6c13608-1d4f-4b6b-a64b-e709ba7208d8"; }
    ];

  powerManagement.cpuFreqGovernor = "ondemand";

  networking = {
    hostId = "567f8775";
    hostName = "cic";
    nameservers = [ "8.8.4.4" "8.8.8.8" ];
    interfaces.eno1 = {
      ipv4 = {
        addresses = [
          { address = "192.168.178.2"; prefixLength = 24; }
          { address = "82.94.130.160"; prefixLength = 32; }
        ];
      };
      ipv6.addresses = [
        { address = "2001:984:3f27:3::2"; prefixLength = 64; }
      ];
    };
    defaultGateway = {
      address = "192.168.178.1";
      interface = "eno1";
    };
    defaultGateway6 = {
      address = "2001:984:3f27:3::1";
      interface = "eno1";
    };
  };

  boot.binfmt.emulatedSystems = [
    "armv6l-linux"
    "armv7l-linux"
    "aarch64-linux"
  ];

  nix = {
    maxJobs = 6;
    distributedBuilds = true;
    buildMachines = [
      { hostName = "localhost";
        systems = [ 
          "builtin" "x86_64-linux" "i686-linux"
          "armv6l-linux" "armv7l-linux" "aarch64-linux"
        ];
        supportedFeatures = ["kvm" "nixos-test" "big-parallel" "benchmark" "local" ];
        maxJobs = 6;
      }
    ];
    extraOptions = ''
      min-free = ${toString (100 * 1024 * 1024 * 1024)}
      max-free = ${toString (500 * 1024 * 1024 * 1024)}
    '';
    autoOptimiseStore = true;
  };
}
