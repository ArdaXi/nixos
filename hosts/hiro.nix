{ lib, pkgs, ... }:

{
  imports = [
    ../profiles/desktop
  ];

  hardware = {
    enableRedistributableFirmware = true;
    opengl.enable = true;
  };

  environment = {
    systemPackages = [ pkgs.cryptsetup ];
    variables = {
      "QT_AUTO_SCREEN_SCALE_FACTOR" = "2";
      "MOZ_USE_XINPUT2" = "1";
    };
    etc = {
      "xdg/xsettingsd/xsettingsd.conf".text = ''
        Xft/Antialias 1
        Xft/HintStyle "hintslight"
        Xft/Hinting 1
        Xft/RGBA "rgb"
        Xft/lcdfilter "lcddefault"
        Xft/DPI ${builtins.toString (96 * 2 * 1024)}

        Gdk/WindowScalingFactor 2
        Gdk/UnscaledDPI ${builtins.toString (96 * 1024)}
      '';
    };
  };

  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.xorg.xrdb}/bin/xrdb -merge <<EOF
    Xft.dpi = 192
    Xcursor.size: 32
    Xcursor.theme: Vanilla-DMZ-AA
    EOF
    ${pkgs.networkmanagerapplet}/bin/nm-applet &
    ${pkgs.xsettingsd}/bin/xsettingsd &
  '';

  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" ];
      luks.devices.cypher.device = "/dev/disk/by-uuid/9c91fb6e-5dc5-4492-982e-adf996479106";
    };

    kernel.sysctl."net.ipv6.route.max_size" = "2147483647";
    kernelModules = [ "kvm-intel" ];

    loader = {
      grub.enable = false;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    supportedFilesystems = [ "zfs" ];
    tmpOnTmpfs = true;
    blacklistedKernelModules = [ "nouveau" ];

    binfmt.emulatedSystems = [
      "armv6l-linux"
      "armv7l-linux"
      "aarch64-linux"
    ];
  };

  fileSystems = {
    "/" = {
      device = "tank/root";
      fsType = "zfs";
    };
    "/nix" = {
      device = "tank/nix";
      fsType = "zfs";
    };
    "/home" = {
      device = "tank/home";
      fsType = "zfs";
    };
    "/boot" = {
      device = "/dev/disk/by-partuuid/ee0faca1-b3ef-4c44-8f27-3ee347032695";
      fsType = "vfat";
    };
  };

  swapDevices = [{
    device = "/dev/disk/by-partuuid/676cab28-d472-4c8e-8a05-518dd2dc19c2";
    randomEncryption = {
      enable = true;
      cipher = "aes-xts-plain64";
      source = "/dev/urandom";
    };
  }];

  nix = {
    maxJobs = 8;
    buildCores = 8;
  };

  networking = {
    hostId = "85703e9c";
    hostName = "hiro";
  };

  system.stateVersion = "18.03";
}
