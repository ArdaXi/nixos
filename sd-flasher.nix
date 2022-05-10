{ pkgs, crossPkgs, config, ... }:

let
  zramLimit = 1024; # Megabytes
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
pkgs.writeShellScriptBin "flash-sd" ''
  set -euo pipefail

  if [[ -z $1 ]]; then
    echo "Usage: $(basename $0) <device>"
    echo "<device>  Block device (like sda) without /dev"
    exit 0
  fi
  if [[ $(< /sys/block/$1/device/model) != "SD/MMC          " ]]; then
    echo "Device /dev/$1 isn't an SD card, aborting"
    exit 1
  fi

  TMPDIR=$(mktemp -d)
  BOOTDIR=$TMPDIR/boot
  ROOTDIR=$TMPDIR/root
  BOOTDEV=/dev/''${1}1
  ROOTDEV=/dev/''${1}2

  echo "Formatting SD card"
  ${pkgs.util-linux}/bin/sfdisk /dev/$1 <<EOF
    label: dos
    label-id: 0x2178694e

    start=${toString imageGap}M, size=${toString bootSize}M, type=b, bootable
    start=${toString(imageGap + bootSize)}M, type=83
  EOF

  echo "Creating boot filesystem"
  ${pkgs.dosfstools}/bin/mkfs.vfat -i 0x2178694e -n ${bootLabel} $BOOTDEV

  ${pkgs.coreutils}/bin/mkdir $BOOTDIR
  ${pkgs.util-linux}/bin/mount -t vfat $BOOTDEV $BOOTDIR

  echo "Populating boot"
  ${config.boot.loader.generic-extlinux-compatible.populateCmd} \
    -c ${config.system.build.toplevel} -d $BOOTDIR -g 0

  ${pkgs.util-linux}/bin/umount $BOOTDEV

  echo "Creating root filesystem"
  ${pkgs.f2fs-tools}/bin/mkfs.f2fs -f -l ${rootLabel} \
    -O extra_attr,inode_checksum,sb_checksum,compression \
    $ROOTDEV

  ${pkgs.coreutils}/bin/mkdir $ROOTDIR
  ${pkgs.util-linux}/bin/mount -t f2fs \
    -o ${builtins.concatStringsSep "," f2fsOptions} \
    $ROOTDEV $ROOTDIR

  ${pkgs.coreutils}/bin/mkdir -p $ROOTDIR/{store,persist/etc}

  echo "Enabling compression for Nix store"
  ${pkgs.e2fsprogs}/bin/chattr -R +c $ROOTDIR/store

  echo "Copying store paths for image"
  xargs -I % cp -a --no-preserve=xattr % -t $ROOTDIR/store < \
    ${closureInfo}/store-paths

  cp ${closureInfo}/registration $ROOTDIR/nix-path-registration

  ${pkgs.util-linux}/bin/umount $ROOTDEV

  echo "Running fsck for /boot"
  ${pkgs.dosfstools}/bin/fsck.vfat -v $BOOTDEV

  echo "Running fsck for /root"
  ${pkgs.f2fs-tools}/bin/fsck.f2fs -fp $ROOTDEV

  echo "Writing sunxi bootloader"
  dd if=${crossPkgs.ubootPine64LTS}/u-boot-sunxi-with-spl.bin of=/dev/$1 \
    bs=1024 seek=8 conv=fsync
''
