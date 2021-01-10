{ modulesPath, config, pkgs, ... }:

{
  imports = [
    ../users/ardaxi
    "${modulesPath}/installer/cd-dvd/sd-image.nix"
  ];

  system.stateVersion = "20.09";

  hardware.enableRedistributableFirmware = true;

  boot = {
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
    initrd.availableKernelModules = [];
    tmpOnTmpfs = true;
  };

  sdImage = {
    populateFirmwareCommands = "";
    postBuildCommands = ''
      dd if=${pkgs.ubootPine64}/u-boot-sunxi-with-spl.bin of=$img bs=1024 seek=8
    '';
    populateRootCommands = ''
      mkdir -p ./files/boot
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
    '';
  };

  services = {
    openssh.enable = true;

    journald.extraConfig = "Storage=volatile";
  };
}
