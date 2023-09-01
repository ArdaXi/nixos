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
    useDHCP = false;
    wireless.iwd.enable = true;
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
  };

  systemd.network = {
    enable = true;

    wait-online.anyInterface = true;

    networks."15-phone" = {
      name = "enp0s20f0u1";
      networkConfig = {
        DHCP = "yes";
      };
    };

    networks."20-dock" = {
      name = "enp0s20f0u4u1";
      address = [ "192.168.178.14/24" "2a10:3781:19df:3::3/64" ];
      gateway = [ "192.168.178.1" ];
      dns = [ "192.168.178.1" ];
    };

    networks."25-wifi" = {
      name = "wlan0";
      networkConfig = {
        DHCP = "yes";
        IgnoreCarrierLoss = "3s";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    google-chrome firefox-bin networkmanagerapplet whois mtr iwgtk
  ];
}
