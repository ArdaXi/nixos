{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.virt-manager
  ];

  virtualisation.virtualbox.host.enable = true;

  virtualisation.libvirtd = {
    enable = true;
#    qemuPackage = pkgs.qemu-patched;
    qemu = {
      swtpm.enable = true;
      ovmf.package = pkgs.OVMFFull;
      runAsRoot = false;
    };
  };

  users.users.ardaxi.extraGroups = [ "libvirtd" ];

  programs.adb.enable = true;
}
