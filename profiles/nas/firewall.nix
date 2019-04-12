{ config, pkgs, ... }:

{
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22 53 80 443
      9001 # Weechat
      8448 # Matrix
      51413 # Transmission
    ];
    allowedUDPPortRanges = [
      { from = 60000; to = 61000; } # mosh
    ];
    allowedUDPPorts = [
      53
      51413 # Transmission
    ];
    extraCommands = ''
      iptables -A nixos-fw -s 192.168.178.0/24 -j nixos-fw-accept
    '';
  };

  services.unifi.openPorts = true;
}
