{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.teams
    pkgs.virt-manager
  ];

  virtualisation.virtualbox.host.enable = true;

  virtualisation.libvirtd = {
    enable = true;
    qemuPackage = pkgs.qemu-patched;
    qemuOvmfPackage = pkgs.OVMFFull;
    qemuSwtpm = true;
    qemuRunAsRoot = false;
  };

  users.users.ardaxi.extraGroups = [ "libvirtd" ];
}
