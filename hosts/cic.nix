{ lib, config, ... }:

{
  imports = [
    ../users/ardaxi
    ../profiles/nas
  ];

  system.stateVersion = "18.03";

  hardware.enableRedistributableFirmware = true;

  services.logind.extraConfig = "HandlePowerKey=ignore";

  boot = {
    loader = {
      grub.enable = false;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd.availableKernelModules = [
      "ahci" "xhci_pci" "ehci_pci" "nvme" "usbhid" "sd_mod" "usb_storage"
    ];
    kernelModules = [ "kvm-intel" ];
    supportedFilesystems = [ "zfs" ];
    tmpOnTmpfs = true;
    tmpOnTmpfsSize = "75%";
    binfmt.emulatedSystems = [ "armv6l-linux" "armv7l-linux" "aarch64-linux" ];

    zfs.extraPools = [ "scratch" ];
  };

  fileSystems = {
    "/" = {
      device = "tank/system/nixos";
      fsType = "zfs";
    };
    "/nix" = {
      device = "tank/local/nix";
      fsType = "zfs";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/B081-027E";
      fsType = "vfat";
    };
    "/media" = {
      device = "tank/data/media";
      fsType = "zfs";
    };
    "/media/tv" = {
      device = "tank/data/media/tv";
      fsType = "zfs";
    };
    "/media/films" = {
      device = "tank/data/media/films";
      fsType = "zfs";
    };
    "/var/lib/postgresql/14" = {
      device = "tank/system/pg14";
      fsType = "zfs";
    };
    "/var/lib/postgresql/14/pg_wal" = {
      device = "tank/system/pg14/wal";
      fsType = "zfs";
    };
    "/var/lib/paperless" = {
      device = "tank/system/paperless";
      fsType = "zfs";
    };
  };

  swapDevices = [{ device = "/dev/disk/by-partuuid/d6c13608-1d4f-4b6b-a64b-e709ba7208d8"; }];

  powerManagement.cpuFreqGovernor = "ondemand";

  networking = {
    hostId = "567f8775";
    hostName = "cic";
    nameservers = [
      "185.93.175.43" "185.232.98.76"
      # TODO: IPv6
    ];
    useDHCP = false;
    interfaces = {
      eno1 = {
        ipv4.addresses = [
          { address = "192.168.178.2"; prefixLength = 24; }
#          { address = "82.94.130.160"; prefixLength = 32; }
        ];
        ipv6.addresses = [{ address = "2a10:3781:19df:3::2"; prefixLength = 64; }];
      };
      eno2 = {
        mtu = 9710;
        ipv4.addresses = [{ address = "10.145.22.1"; prefixLength = 24; }];
        ipv6.addresses = [{ address = "fd08:1432:1eb8::1"; prefixLength = 64; }];
      };
    };
    defaultGateway = {
      address = "192.168.178.1";
      interface = "eno1";
    };
    defaultGateway6 = {
      address = "2a10:3781:19df:3::1";
      interface = "eno1";
    };
  };

  nix = {
    maxJobs = 6;
    buildMachines = [{
      hostName = "localhost";
      systems = [
        "builtin" "x86_64-linux" "i686-linux"
        "armv6l-linux" "armv7l-linux" "aarch64-linux"
      ];
      supportedFeatures = [ "kvm" "nixos-test" "big-parallel" "benchmark" "local" ];
      maxJobs = 6;
    }];
    extraOptions = ''
      min-free = ${toString ( 10 * 1024 * 1024 * 1024)}
      max-free = ${toString (100 * 1024 * 1024 * 1024)}
    '';
    autoOptimiseStore = true;
  };
}
