{ modulesPath, config, pkgs, lib, ... }:

let
  zramLimit = 512; # Amount of RAM used by tmp root in MB
  bootSize = 248; # Megabytes
  rootLabel = "NIXOS_SD";
  bootLabel = "NIXOS_BOOT";
  f2fsOptions = [
    "nodiscard"
    "noatime"
    "compress_algorithm=zstd:6"
  ];
  persistDir = "/nix/persist";
  imageGap = 8; # Megabytes
  closureInfo = pkgs.buildPackages.closureInfo {
    rootPaths = [ config.system.build.toplevel ];
  };
in
{
  imports = [
    ../users/ardaxi
  ];

  system = {
    stateVersion = "20.09";
    requiredKernelConfig = with config.lib.kernelConfig; [
      (isModule "ZRAM")
      (isEnabled "CRYPTO_ZSTD")
    ];
    build.closureInfo = closureInfo;
  };

  boot = {
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
    initrd = {
      availableKernelModules = [];
      extraUtilsCommands = ''
        copy_bin_and_libs ${pkgs.util-linux}/sbin/zramctl
        copy_bin_and_libs ${pkgs.e2fsprogs}/bin/mke2fs
      '';
      extraUtilsCommandsTest = ''
        $out/bin/zramctl --version
        $out/bin/mke2fs -V
      '';
      preLVMCommands = ''
        modprobe zstd
        modprobe zram
        zramctl --size ${toString (zramLimit * 2)}M --algorithm zstd /dev/zram0
        echo ${toString zramLimit}M > /sys/block/zram0/mem_limit
        mke2fs -t ext4 /dev/zram0
      '';
      kernelModules = [ "zram" "zstd" "zstd_compress" "crypto_zstd" ];
    };
    tmpOnTmpfs = true;
    kernelModules = [ "zram" "zstd" "zstd_compress" "crypto_zstd" ];
    kernelPackages = pkgs.linuxPackages_latest;
  };

  fileSystems = {
    "/" = {
      device = "/dev/zram0";
      fsType = "ext4";
      options = [ "discard" ];
      noCheck = true;
    };
    "/boot" = {
      device = "/dev/disk/by-label/${bootLabel}";
      fsType = "vfat";
    };
    "/nix" = {
      device = "/dev/disk/by-label/${rootLabel}";
      fsType = "f2fs";
      options = f2fsOptions;
      autoResize = false;
    };
    "/etc/nixos" = {
      device = "/nix/persist/etc/nixos";
      fsType = "none";
      options = [ "bind" ];
    };
  };

  environment.etc = lib.genAttrs [
    "machine-id"
    "ssh/ssh_host_rsa_key"
    "ssh/ssh_host_rsa_key.pub"
    "ssh/ssh_host_ed25519_key"
    "ssh/ssh_host_ed25519_key.pub"
  ] (path: { source = "${persistDir}/etc/${path}"; });

  services = {
    openssh.enable = true;

    journald.extraConfig = "Storage=volatile";
  };

  users = {
    mutableUsers = false;
    users.root.initialHashedPassword = "";
  };
}
