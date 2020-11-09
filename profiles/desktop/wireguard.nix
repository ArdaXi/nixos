{ config, pkgs, ... }:

let
  peer = "gOOVDekwhhQDUwMaiy8seqPkatztyTfA9laiSRLxEGc=";
  endpoint = "82.161.251.166:51820";
  wgResetPreUp = pkgs.writeText "wg-reset" ''
    ${pkgs.wireguard-tools}/bin/wg set wg0 peer ${peer} endpoint ${endpoint}
  '';
  wgReset = pkgs.writeText "wg-reset" ''
    ${pkgs.wireguard-tools}/bin/wg set wg0 peer ${peer} endpoint ${endpoint}
    sleep 5
    ${pkgs.wireguard-tools}/bin/wg set wg0 peer ${peer} endpoint ${endpoint}
  '';

in
{
  networking = {
    wireguard.interfaces.wg0 = {
      allowedIPsAsRoutes = false;
      ips = [ "82.94.130.163" "192.168.177.2" "2001:984:3f27:2::2" ];
      listenPort = 51820;
      peers = [{
        allowedIPs = [ "0.0.0.0/0" "::/0" ];
        endpoint = endpoint;
        persistentKeepalive = 25;
        publicKey = peer;
      }];
      preSetup = [
        # The "|| true" is because the script fails if the postShutdown hasn't
        # run properly.
        # Send all packets without fwmark (so not from wireguard)
        "ip rule add not fwmark 0xca6c table 51820 || true" # …to table 51820
        # …except if there's a more specific route…
        "ip rule add table main suppress_prefixlength 0 || true" 
        # …or it's headed to the WG endpoint
        "ip rule add table main to 82.161.251.166 || true" 
        # The last shouldn't be needed but hey

        # The same for IPv6
        "ip -6 rule add not fwmark 0xca6c table 51820 || true"
        "ip -6 rule add table main suppress_prefixlength 0 || true"
      ];
      postSetup = [
        # Set the fwmark on all encrypted WG packets
        "wg set wg0 fwmark 0xca6c"
        # Route all traffic from our public IP...
        "ip route add default dev wg0 src 82.94.130.163 table 51820"
        # ...unless it's to a private space
        "ip route add 192.168.0.0/16 dev wg0 src 192.168.177.2 table 51820"
        # The most specific route will always be chosen. When connected to a
        # private LAN directly, this route will be bypassed by the
        # suppress_prefixlength rule.

        "ip -6 route add default dev wg0 table 51820" # Only one address,
        # no source address needed here.
      ];
      postShutdown = [
        # No need to remove the route here because that disappears when the wg0
        # interface does.
        "ip rule del not fwmark 0xca6c table 51820 || true"
        "ip rule del table main suppress_prefixlength 0 || true"
        "ip rule del table main to 82.161.251.166 || true"
        "ip -6 rule del not fwmark 0xca6c table 51820 || true"
        "ip -6 rule del table main suppress_prefixlength 0 || true"
      ];
      privateKeyFile = "/var/wg/privatekey";
    };

    firewall.allowedUDPPorts = [ 51820 ];
  
    networkmanager.dispatcherScripts = [
      { source = wgResetPreUp; type = "pre-up"; }
      { source = wgReset; type = "basic"; }
    ];
  };
}
