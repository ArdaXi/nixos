{ lib, config, pkgs, ... }:

with lib;

let
  nixos_release = import (pkgs.path + "/nixos/release.nix") {};
  netboot = let
    build = (import (pkgs.path + "/nixos/lib/eval-config.nix") {
      system = "x86_64-linux";
      modules = [
        (pkgs.path + "/nixos/modules/installer/netboot/netboot-minimal.nix")
        ../machines/netboot.nix
      ];
    }).config.system.build;
  in pkgs.symlinkJoin {
    name = "netboot";
    paths = with build; [ netbootRamdisk kernel netbootIpxeScript ];
  };
  tftp_root = pkgs.runCommand "tftproot" {} ''
    mkdir -pv $out
    cp -vi ${pkgs.ipxe}/undionly.kpxe $out/undionly.kpxe.0
  '';
  nginx_root = pkgs.runCommand "nginxroot" {} ''
    mkdir -pv $out
    cat <<EOF > $out/boot
    #!ipxe
    chain netboot/netboot.ipxe
    EOF
    ln -sv ${netboot} $out/netboot
  '';
in {
  services.nginx = {
    enable = true;
    virtualHosts = {
      "192.168.178.22" = {
        root = nginx_root;
      };
    };
  };
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;
    extraConfig = ''
      port=0
      log-dhcp
      tftp-root=${tftp_root}
      dhcp-range=192.168.178.0,proxy
      pxe-service=x86PC, "iPXE", undionly.kpxe
      dhcp-boot=undionly.kpxe.0
    '';
  };
}
