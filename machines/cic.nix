{ config, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
    ../profiles/default.nix
  ];

  boot = {
    initrd = {
      availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront"];
      supportedFilesystems = [ "ext4" ];
    };
    kernelModules = [ "kvm-intel" ];
    kernelParams = [ "boot.shell_on_fail" ];
    loader.grub = {
      enable = true;
      version = 2;
      device = "/dev/xvda";
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };
  };

  networking = {
    hostId = "8425e349";
    hostName = "cic";
  };

  nix.maxJobs = 1;
}
