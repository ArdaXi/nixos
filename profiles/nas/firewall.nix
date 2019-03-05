{ config, pkgs, ... }:

{
  services.nfs.server = {
    statdPort = 4000;
    mountdPort = 4001;
    lockdPort = 4002;
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22 53 80 443
    ];
    allowedUDPPortRanges = [
      { from = 60000; to = 61000; }
      { from = 4000; to = 4002; }
    ];
    allowedUDPPorts = [
      53
    ];
    extraCommands = ''
      ip46tables -A nixos-fw -s 192.168.178.0/24 -j nixos-fw-accept
    '';
  };

  services.unifi.openPorts = true;
}
