{ config, lib, ... }:

{
  networking.firewall = {
    enable = true;
    logRefusedConnections = false;
    allowedTCPPorts = [
      (lib.mkIf config.services.openssh.enable 22)
      (lib.mkIf config.services.bind.enable 53)
      (lib.mkIf config.services.nginx.enable 80)
      (lib.mkIf config.services.nginx.enable 443)
      (lib.mkIf config.services.matrix-synapse.enable 8448)
      (lib.mkIf config.services.transmission.enable 51413)
      9001 # Weechat
    ];
    allowedUDPPortRanges = [
      (lib.mkIf config.programs.mosh.enable { from = 60000; to = 61000; })
    ];
    allowedUDPPorts = [
      (lib.mkIf config.services.bind.enable 53)
      (lib.mkIf config.services.transmission.enable 51413)
    ];
    extraCommands = ''
      iptables -A nixos-fw -s 192.168.178.0/24 -j nixos-fw-accept
      iptables -A nixos-fw -s 192.168.179.22/32 -j nixos-fw-accept
      iptables -A nixos-fw -s 192.168.179.0/24 -p tcp --dport 1883 -j nixos-fw-accept
    '';
  };

  services.unifi.openPorts = true;

  services.fail2ban.enable = true;
}
