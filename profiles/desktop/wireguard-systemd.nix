{ config, pkgs, lib, ... }:

let
  interface = "wg0";
  publicIP = "82.94.130.163";
  localIP = "192.168.177.2";
  sixIP = "2001:984:3f27:2::2";
  peer = "gOOVDekwhhQDUwMaiy8seqPkatztyTfA9laiSRLxEGc=";
  endpointIP = "45.83.235.250";
  endpointPort = "53";
  endpoint = "${endpointIP}:${endpointPort}";
  magicno = 51820; # Port, table, fwmark, etc...
  rule = "not fwmark 0x${lib.toHexString magicno} table ${toString magicno}";
  ipBin = "${pkgs.iproute}/bin/ip";
in {
  environment.systemPackages = [
    pkgs.wireguard-tools
    (pkgs.writeShellScriptBin "vpn" ''
      if [[ $1 == "enable" ]]; then
        ${ipBin} rule add ${rule}
        ${ipBin} rule add table main suppress_prefixlength 0
        ${ipBin} rule add table main to ${endpointIP}
      elif [[ $1 == "disable" ]]; then
        ${ipBin} rule del ${rule}
        ${ipBin} rule del table main suppress_prefixlength 0
        ${ipBin} rule del table main to ${endpointIP}
      elif [[ $1 == "reset" ]]; then
        ${pkgs.wireguard-tools}/bin/wg set ${interface} peer ${peer} endpoint ${endpoint}
      else
        echo "Usage: $(basename $0) {enable|disable|reset}"
        if [[ $(${ipBin} rule list all ${rule}) ]]; then
          echo "Currently enabled";
        else
          echo "Currently disabled";
        fi
      fi
    '')
  ];

  networking.firewall.allowedUDPPorts = [ magicno ];

  services.openssh.openFirewall = false;

  systemd.network = {
    enable = true;

    netdevs."10-wg" = {
      netdevConfig = {
        Kind = "wireguard";
        MTUBytes = "1420";
        Name = interface;
      };

      wireguardConfig = {
        PrivateKeyFile = "/var/wg/privatekey";
        ListenPort = magicno;
        FirewallMark = magicno;
      };

      wireguardPeers = [{ wireguardPeerConfig = {
        Endpoint = endpoint;
        PublicKey = peer;
        AllowedIPs = [ "0.0.0.0/0" "::/0"];
        PersistentKeepalive = 25;
      };}];
    };

    networks."40-wg" = {
      name = interface;
      address = [ "${publicIP}/32" "${localIP}/32" "${sixIP}/128" ];
      routes = [
      # Set up a routing table that routes all traffic through WG
        { routeConfig = {
          # With the public IP as a source
          PreferredSource = publicIP;
#          PreferredSource = localIP;
          Table = magicno;
          Scope = "link";
        };}
        { routeConfig = {
          # Unless the destination is local
          Destination = "192.168.0.0/16";
          PreferredSource = localIP;
          Table = magicno;
          Scope = "link";
        };}
        { routeConfig = {
          # For IPv6, only one IP is used.
          PreferredSource = sixIP;
          Table = magicno;
          Scope = "link";
        };}
      ];
      routingPolicyRules = [ { "routingPolicyRuleConfig" = {
        # If there is a specific (not default) route in the main table, use it.
        Family = "both";
        SuppressPrefixLength = 0;
        Priority = 10;
      };}];
    };
  };
}
