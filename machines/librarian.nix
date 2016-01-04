{ config, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
    ../profiles/default.nix
    ../profiles/bouncer.nix
  ];

  boot = {
    initrd = {
      availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "virtio_blk" ];
      supportedFilesystems = [ "ext4" ];
      postDeviceCommands = ''
        mkdir -p /mnt-root/old-root ;
        mount -t ext4 /dev/vda1 /mnt-root/old-root ;
      '';
    };
    kernelModules = [ "kvm-intel" ];
    kernelParams = [ "boot.shell_on_fail" ];
    loader.grub = {
      enable = true;
      version = 2;
      device = "/dev/vda";
      storePath = "/nixos/nix/store";
    };
  };

  fileSystems = {
    "/" = {
      device = "/old-root/nixos";
      fsType = "none";
      "options" = "bind";
    };

    "/old-root" = {
      device = "/dev/vda1";
      fsType = "ext4";
    };
  };

  networking = {
    hostId = "3eb2a8ec";
    hostName = "librarian";
    interfaces.eth0.useDHCP = false;
    interfaces.eth1.useDHCP = false;
  };

  systemd.services.setup-network = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.bash}/bin/bash -i /etc/nixos-in-place/setup-network";
    };
  };

  nix.maxJobs = 1;
}
