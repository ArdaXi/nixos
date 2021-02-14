{ config, lib, pkgs, ... }:

let
  imageName = "nixos-sd-image-${config.system.nixos.label}-" + 
    "${config.networking.hostName}-${pkgs.stdenv.hostPlatform.system}.img";
  closureInfo = pkgs.buildPackages.closureInfo {
    rootPaths = [ config.system.build.toplevel ];
  };
  imageGap = 8; # in megabytes
  imageLabel = "NIXOS_SD";
  rootUUID = "44444444-4444-4444-8888-888888888888";
  rootDir = "/nix"; # mountpoint for root partition
  persistDir = "${rootDir}/persist";
  zramSize = "512M";
  zramLimit = "256M";
in
{
  system.requiredKernelConfig = with config.lib.kernelConfig; [
    (isModule "ZRAM")
    (isEnabled "CRYPTO_ZSTD")
  ];

  boot.extraModprobeConfig = "options zram num_devices=1";

  boot.kernelModules = [ "zram" "zstd" "zstd_compress" "crypto_zstd" ];

  fileSystems = {
    "/" = {
      device = "/dev/zram0";
      fsType = "ext4";
      options = [ "discard" ];
      noCheck = true;
    };
    "/nix" = {
      device = "/dev/disk/by-label/${imageLabel}";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/nix/boot";
      fsType = "none";
      options = [ "bind" ];
    };
    "/etc/nixos" = {
      device = "/nix/persist/etc/nixos";
      fsType = "none";
      options = [ "bind" ];
    };
  };

  environment.etc = {
    "machine-id".source = "${persistDir}/etc/machine-id";
    "ssh/ssh_host_rsa_key".source = "${persistDir}/etc/ssh/ssh_host_rsa_key";
    "ssh/ssh_host_rsa_key.pub".source = "${persistDir}/etc/ssh/ssh_host_rsa_key.pub";
    "ssh/ssh_host_ed25519_key".source = "${persistDir}/etc/ssh/ssh_host_ed25519_key";
    "ssh/ssh_host_ed25519_key.pub".source = "${persistDir}/etc/ssh/ssh_host_ed25519_key.pub";
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd = {
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
      zramctl --size ${zramSize} --algorithm zstd /dev/zram0
      echo ${zramLimit} > /sys/block/zram0/mem_limit
      mke2fs -t ext4 /dev/zram0
    '';
    kernelModules = [ "zram" "zstd" "zstd_compress" "crypto_zstd" ];
  };

  system.build.sdImage = pkgs.callPackage ({ stdenv, dosfstools, e2fsprogs,
    mtools, libfaketime, fakeroot, util-linux }: stdenv.mkDerivation {
      name = imageName;

      nativeBuildInputs = [ dosfstools e2fsprogs mtools libfaketime fakeroot util-linux ];

      buildCommand = ''
        # Yes, mkfs.ext4 takes different units in different contexts. Fun.
        sectorsToKilobytes() {
          echo $(( ( "$1" * 512 ) / 1024 ))
        }
        sectorsToBytes() {
          echo $(( "$1" * 512  ))
        }

        mkdir -p $out/nix-support $out/sd-image
        export img=$out/sd-image/$name

        echo "${pkgs.stdenv.buildPlatform.system}" > $out/nix-support/system

        mkdir -p ./rootImage/persist/etc/{nixos,ssh}

        echo "Adding bootloader configuration..."
        mkdir -p ./rootImage/boot
        ${config.boot.loader.generic-extlinux-compatible.populateCmd} \
          -c ${config.system.build.toplevel} -d ./rootImage/boot

        echo "Copying store paths for image..."
        mkdir -p ./rootImage/store
        xargs -I % cp -a --reflink=auto % -t ./rootImage/store < \
          ${closureInfo}/store-paths

        cp ${closureInfo}/registration ./rootImage/nix-path-registration

        numInodes=$(find ./rootImage | wc -l)
        numDataBlocks=$(du -s -c -B 4096 --apparent-size ./rootImage | tail -1 | \
          awk '{ print int($1 * 1.10) }')
        bytes=$((2 * 4096 * $numInodes + 4096 * $numDataBlocks))
        echo "Calculated size for ext4 partition: $bytes bytes"
        echo "numInodes: $numInodes | numDataBlocks: $numDataBlocks"

        imgSize=$((bytes + ${toString(imageGap * 1024 * 1024)}))
        truncate -s $imgSize $img

        sfdisk $img <<EOF
          label: dos
          label-id: 0x2178694e

          start=${toString(imageGap)}M, type=83, bootable
        EOF

        echo "Finding sectors"
        eval $(partx $img -o START,SECTORS --nr 1 --pairs)
        echo "Creating ext4 partition with data"
        #faketime -f "1970-01-01 00:00:01" fakeroot mkfs.ext4 -F -L ${imageLabel} \
        mkfs.ext4 -F -L ${imageLabel} \
          -U ${rootUUID} -d ./rootImage \
          $img \
          -E offset=$(sectorsToBytes $START) $(sectorsToKilobytes $SECTORS)K

        echo "Writing sunxi bootloader"
        dd if=${pkgs.ubootPine64}/u-boot-sunxi-with-spl.bin of=$img bs=1024 seek=8 \
          conv=notrunc

        echo "Image done"
      '';
    }) {};

  boot.postBootCommands = ''
    set -euo pipefail
    set -x
    if [ -f ${rootDir}/nix-path-registration ]; then
      # Figure out device names for the boot device and root filesystem.
      rootPart=$(${pkgs.util-linux}/bin/findmnt -n -o SOURCE ${rootDir})
      bootDevice=$(lsblk -npo PKNAME $rootPart)
      partNum=$(lsblk -npo MAJ:MIN $rootPart | ${pkgs.gawk}/bin/awk -F: '{print $2}')

      # Resize the root partition and the filesystem to fit the disk
      echo ",+," | sfdisk -N$partNum --no-reread $bootDevice
      ${pkgs.parted}/bin/partprobe
      ${pkgs.e2fsprogs}/bin/resize2fs $rootPart

      # Register contents of initial Nix store
      ${config.nix.package}/bin/nix-store --load-db < ${rootDir}/nix-path-registration

      # Set profile
      ${config.nix.package}/bin/nix-env -p /nix/var/nix/profiles/system \
        --set /run/current-system

      rm -f ${rootDir}/nix-path-registration
    fi

    touch /etc/NIXOS

    # TODO: Copy files backed up on shutdown?
  '';
}
