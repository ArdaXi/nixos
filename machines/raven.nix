{ config, pkgs, ... }:

{
  imports = [
    ../profiles/default.nix
    ../profiles/default-programs.nix
    ../profiles/desktop.nix
    ../profiles/project.nix
  ];

  environment.systemPackages = with pkgs; [
    cryptsetup
  ];

  networking.hostName = "raven";
  networking.hostId = "85703e9c";

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sdb";

  boot.supportedFilesystems = [ "zfs" ];
}
