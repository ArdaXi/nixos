{ config, pkgs, ... }:

let
  peer = "gOOVDekwhhQDUwMaiy8seqPkatztyTfA9laiSRLxEGc=";
  endpoint = "router.street.ardaxi.com:51820";
  wgReset = pkgs.writeText "wg-reset" ''
    ${pkgs.wireguard-tools}/bin/wg set wg0 peer ${peer} endpoint ${endpoint}
  '';
in
{
  networking = {
    wireguard.interfaces.wg0 = {
      ips = [ "82.94.130.163/31" ];
      listenPort = 51820;
      peers = [{
        allowedIPs = [ "0.0.0.0/0" ];
        endpoint = endpoint;
        persistentKeepalive = 25;
        publicKey = peer;
      }];
      preSetup = [
        "ip rule add not fwmark 0xca6c table 51820"
        "ip rule add table main suppress_prefixlength 0"
        "ip rule add table main to 82.161.251.166" 
        "ip route add default wg0 table 51820"
      ];
      postSetup = [
        "wg set wg0 fwmark 0xca6c"
      ];
      postShutdown = [
        "ip rule del not fwmark 0xca6c table 51820"
        "ip rule del table main suppress_prefixlength 0"
        "ip rule del table main to 82.161.251.166" 
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
