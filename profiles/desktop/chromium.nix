{ config, pkgs, ... }:

let
  startPort = 60001;
  endPort = 60999;
in
{
  networking.firewall.allowedUDPPortRanges = [
    { from = startPort; to = endPort; }
  ];

  programs.chromium = {
    enable = true;
    extraOpts = {
      WebRtcUdpPortRange = "${toString startPort}-${toString endPort}";
    };
  };

  boot.kernel.sysctl."net.ipv4.ip_local_port_range" = "32768 ${toString (startPort - 1)}";
}
