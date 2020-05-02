{ config, pkgs, ... }:

let
  nvidia_x11 = config.boot.kernelPackages.nvidia_x11;
  nvidia_gl = nvidia_x11.out;
  nvidia_gl_32 = nvidia_x11.lib32;
in
{
  imports = [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ../profiles/default.nix
    ../profiles/desktop-full.nix
    ../profiles/project.nix
    ../modules/wlanfixes.nix
  ];

  hardware.bumblebee = {
    driver = "nvidia";
    enable = true;
  };

  hardware.opengl = {
    enable = true;
    extraPackages = [ nvidia_gl ];
    extraPackages32 = [ nvidia_gl_32 ];
  };

  services.xserver.dpi = 192;

# DPI stuff

  environment.variables.QT_AUTO_SCREEN_SCALE_FACTOR = "2";
  environment.variables.MOZ_USE_XINPUT2 = "1";
  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.xorg.xrdb}/bin/xrdb -merge <<EOF
    Xft.dpi: 192
    Xcursor.size: 32
    Xcursor.theme: Vanilla-DMZ-AA
    EOF
    ${pkgs.networkmanagerapplet}/bin/nm-applet &
    ${pkgs.xsettingsd}/bin/xsettingsd &
  '';
  environment.systemPackages = [ (pkgs.writeTextFile {
    name = "xsettings";
    destination = "/etc/xdg/xsettingsd/xsettingsd.conf";
    text = ''
      Xft/Antialias 1
      Xft/HintStyle "hintslight"
      Xft/Hinting 1
      Xft/RGBA "rgb"
      Xft/lcdfilter "lcddefault"
      Xft/DPI ${builtins.toString (96 * 2 * 1024)}

      Gdk/WindowScalingFactor 2
      Gdk/UnscaledDPI ${builtins.toString (96 * 1024)}
    '';
  }) pkgs.cryptsetup nvidia_x11 ];

# /DPI stuff

  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" ];
#      kernelModules = [ "fbcon" ];
      luks.devices = {
        cypher = { device = "/dev/disk/by-uuid/9c91fb6e-5dc5-4492-982e-adf996479106"; };
      };
    };

    kernelModules = [
      "kvm-intel"
     # "fbcon"
    ];

    loader = {
      grub.enable = false;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    supportedFilesystems = [ "zfs" ];

    tmpOnTmpfs = true;

    extraModulePackages = [ nvidia_x11 ];
    blacklistedKernelModules = [ "nouveau" ];
  };

  fileSystems."/" = {
    device = "tank/root";
    fsType = "zfs";
  };

  fileSystems."/nix" = {
    device = "tank/nix";
    fsType = "zfs";
  };

  fileSystems."/home" = {
    device = "tank/home";
    fsType = "zfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-partuuid/ee0faca1-b3ef-4c44-8f27-3ee347032695";
    fsType = "vfat";
  };

  swapDevices = [ {
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

    networkmanager.unmanaged = [ "interface-name:wlp4s0" "interface-name:wlanzap0" ];
  };

  ardaxi.wlanInterfaces = {
    "wlanclient0" = { device = "wlp4s0"; mac = "00:24:d6:f9:8a:ad"; };
    "wlanzap0" = { device = "wlp4s0"; mac = "f2:a5:33:1b:23:c5"; type = "__ap"; };
  };

  system.stateVersion = "18.03";
}
