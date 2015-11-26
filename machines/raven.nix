{ config, pkgs, ... }:

{
  imports = [
    ../profiles/desktop.nix
    ../profiles/project.nix
  ];

  environment.systemPackages = with pkgs; [
    cryptsetup
  ];

  networking.hostId = "85703e9c";

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sdb";

  boot.supportedFilesystems = [ "zfs" ];
}
