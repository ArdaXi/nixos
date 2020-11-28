{ ... }:

{
  imports = [
    ../users/ardaxi
  ];

  system.stateVersion = "20.09";

  hardware.enableRedistributableFirmware = true;

  boot = {
    loader = {
      grub.enable = false;
    };
    initrd.availableKernelModules = [
    ];
    tmpOnTmpfs = true;
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };
}
