{ pkgs, ... }:

{
  services.resolved = {
    enable = true;
    dnssec = "true";
    fallbackDns = [
      # XS4ALL
      "194.109.6.66"
      "194.109.9.99"
      "194.109.104.104"
      "2001:888:0:6::66"
      "2001:888:0:9::99"

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
    };

    networkmanager = {
      enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    google-chrome firefox-bin networkmanagerapplet whois mtr
  ];
}
