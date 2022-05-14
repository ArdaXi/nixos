{ pkgs, ... }:

{
  services.resolved = {
    enable = true;
    dnssec = "allow-downgrade";
    fallbackDns = [
      # Quad9
      "9.9.9.9"
      "149.112.112.112"
      "2620:fe::fe"
      "2620:fe::9"

      # OpenDNS
      "208.67.222.222"
      "208.67.220.220"
    ];
  };

  networking = {
    firewall = {
      logRefusedConnections = false;
      extraCommands = ''
        iptables -A nixos-fw -s 192.168.178.0/24 -j nixos-fw-accept -i enp0s20f0u4u1
      ''; # Open requests from local (trusted) network

      allowedUDPPorts = [
        21027 22000 # Syncthing
      ];

      allowedTCPPorts = [
        22000 # Syncthing
      ];
    };

    networkmanager = {
      enable = true;
      unmanaged = [ "street" ];
    };
  };

  environment.systemPackages = with pkgs; [
    google-chrome firefox-bin networkmanagerapplet whois mtr
  ];
}
