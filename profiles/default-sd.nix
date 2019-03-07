{ config, pkgs, lib, ... }:

let
  extlinux-conf-builder =
    import <nixpkgs/nixos/modules/system/boot/loader/generic-extlinux-compatible/extlinux-conf-builder.nix> {
      pkgs = pkgs.buildPackages;
    };
in
{
  imports = [
    <nixpkgs/nixos/modules/profiles/installation-device.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/sd-image.nix>
  ];


  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  boot.consoleLogLevel = lib.mkDefault 7;

  # The serial ports listed here are:
  # - ttyS0: for Tegra (Jetson TX1)
  # - ttyAMA0: for QEMU's -machine virt
  # Also increase the amount of CMA to ensure the virtual console on the RPi3 works.
  boot.kernelParams = ["cma=32M" "console=ttyS0,115200n8" "console=ttyAMA0,115200n8" "console=tty0"];

  sdImage = {
    populateBootCommands = let
      configTxt = pkgs.writeText "config.txt" ''
        kernel=u-boot-rpi3.bin

        # Boot in 64-bit mode.
        arm_control=0x200

        # U-Boot used to need this to work, regardless of whether UART is actually used or not.
        # TODO: check when/if this can be removed.
        enable_uart=1

        # Prevent the firmware from smashing the framebuffer setup done by the mainline kernel
        # when attempting to show low-voltage or overtemperature warnings.
        avoid_warnings=1
      '';
      in ''
        (cd ${pkgs.raspberrypifw}/share/raspberrypi/boot && cp bootcode.bin fixup*.dat start*.elf $NIX_BUILD_TOP/boot/)
        cp ${pkgs.ubootRaspberryPi3_64bit}/u-boot.bin boot/u-boot-rpi3.bin
        cp ${configTxt} boot/config.txt
        ${extlinux-conf-builder} -t 3 -c ${config.system.build.toplevel} -d ./boot
      '';
  };

  nix = {
    package = pkgs.nixUnstable;
    binaryCachePublicKeys = [ "street.ardaxi.com-1:A1P6oGDAlLPtBbscHNTzBM6DpMHGpqLNwXUgmOtNegg=" "arm.cachix.org-1:fGqEJIhp5zM7hxe/Dzt9l9Ene9SY27PUyx3hT9Vvei0=" ];
    binaryCaches = [ https://cache.nixos.org/ http://nix-cache.street.ardaxi.com/ https://arm.cachix.org/ ];
  };
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = true;
      android_sdk.accept_license = true;
    };
    overlays = (import ../overlays);
  };

  hardware.enableAllFirmware = true;

  time.timeZone = "Europe/Amsterdam";

  i18n = {
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  users.extraUsers.ardaxi = {
    name = "ardaxi";
    group = "ardaxi";
    extraGroups = [
      "users"
      "wheel"
      "networkmanager"
      "audio"
      "adbusers"
    ];
    uid = 1000;
    home = "/home/ardaxi";
    createHome = true;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCnEDvMXrD7Hh3iQC42v2RlVs386cs3f2Z9UfTwblK8Qj65KqMoIqbNw6X0c0hW0dwYArAdQmxJBhynS+ajoNs0I+WY+SLT1DHPx/KejepzlQEYpmlSXp7bTc4B68iTy3nqTbmbxyHDHAfBeEoMDctGzuqr1wHTBM3oxaWn37OxoNQOux/RnjPWLQpv7UmUniUimrn1f6aEX93SO7GqVzqPzG3FnwcAtEaTw2tWeE349T8eG+Qf+17w/3YRwzRll9G8FKEcInnnpMSXEghkW6wZP99WeNDuOTPK9EYeb/oEOEZEvk8DXFzbDNSxBG5F2riRXL2JW1pQxYPemmiGIlnehxm1qLZ465v/LvdKS3ice6WD8s52cQaPUQiFvRxfrnfxxLxKb3mxmZJJtenIrvvDXVgmmJ+31qk0x8O8ZaaZZUI6XKw3HyfqXOgjrj1T+ppB2wNOIrKysKVbb26fviBwGGFOq9Kp/qyNcM1hMh8U7KWzUnzb77Yw1x3AzYwyf6y9i49XuxYJzrud+5yJbj9rtWby748grENM6KMVjPv8D//3MFmLKeHuohR4Ft+yBTWCbYrZU8dV5KBVfK8he2lDHG9gDCdGKjXn9jngFWBdHaXixtMMQHC0dZmycATnnR5acoN52xzj/K0sVod3jqrpT/J+SxVHbw2OpruVx6Qs+Q== openpgp:0xADB81AB8" #5C
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC9L+dgqEWlz1HCAFvOo2WMcxXUCVZjEENrSCHEHdGKx ardaxi@hiro"
    ];
  };
  users.extraGroups.ardaxi.gid = 1000;

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = lib.mkForce "no";
  };

  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    mosh
    psmisc
    binutils
    git
    gitAndTools.gitflow
  ];

  environment.extraInit = "export XDG_CONFIG_DIRS=/etc/xdg:$XDG_CONFIG_DIRS";
}
