{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.teams
    pkgs.virt-manager
  ];

  virtualisation.virtualbox.host.enable = true;

  virtualisation.libvirtd = {
    enable = true;
    qemuOvmfPackage = pkgs.OVMFFull;
    qemuSwtpm = true;
    qemuRunAsRoot = false;
  };

  users.users.ardaxi.extraGroups = [ "libvirtd" ];
}
