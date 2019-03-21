{ config, pkgs, ... }:

let
  peer = "gOOVDekwhhQDUwMaiy8seqPkatztyTfA9laiSRLxEGc=";
  endpoint = "82.161.251.166:51820";
  wgReset = pkgs.writeText "wg-reset" ''
    ${pkgs.wireguard-tools}/bin/wg set wg0 peer ${peer} endpoint ${endpoint}
  '';
in
{
  networking = {
    wireguard.interfaces.wg0 = {
      allowedIPsAsRoutes = false;
      ips = [ "82.94.130.163/31" ];
      listenPort = 51820;
      peers = [{
        allowedIPs = [ "0.0.0.0/0" ];
        endpoint = endpoint;
        persistentKeepalive = 25;
        publicKey = peer;
      }];
      preSetup = [
        "ip rule add not fwmark 0xca6c table 51820 || true"
        "ip rule add table main suppress_prefixlength 0 || true"
        "ip rule add table main to 82.161.251.166 || true"
      ];
      postSetup = [
        "wg set wg0 fwmark 0xca6c"
        "ip route add default dev wg0 table 51820"
      ];
      postShutdown = [
        "ip rule del not fwmark 0xca6c table 51820 || true"
        "ip rule del table main suppress_prefixlength 0 || true"
        "ip rule del table main to 82.161.251.166 || true"
      ];
      privateKeyFile = "/var/wg/privatekey";
    };

    firewall.allowedUDPPorts = [ 51820 ];
  
    networkmanager.dispatcherScripts = [
      { source = wgReset; type = "pre-up"; }
      { source = wgReset; type = "basic"; }
    ];
  };
}
