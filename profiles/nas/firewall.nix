{ config, pkgs, ... }:

{
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22 53 80 443
    ];
    allowedUDPPortRanges = [
      { from = 60000; to = 61000; }
    ];
    allowedUDPPorts = [
      53
    ];
    extraCommands = ''
      iptables -A nixos-fw -s 192.168.178.0/24 -j nixos-fw-accept
    '';
  };

  services.unifi.openPorts = true;
}
