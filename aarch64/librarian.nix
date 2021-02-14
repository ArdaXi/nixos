{ modulesPath, config, pkgs, ... }:

{
  imports = [
    ../users/ardaxi
    ../profiles/pine/sd-image.nix
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

  services = {
    openssh.enable = true;

    journald.extraConfig = "Storage=volatile";
  };

  users = {
    mutableUsers = false;
    users.root.initialHashedPassword = "";
  };
}
