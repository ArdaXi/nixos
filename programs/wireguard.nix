{ config, pkgs, ... }:

{
  networking.wireguard.interfaces.wg0 = {
    ips = [ "192.168.177.2/24" ];
    peers = [ {
      allowedIPs = [ "0.0.0.0/0" "::/0" ];
      endpoint = "82.161.251.166:53";
      publicKey = "Ez5OhMCNwZ2aoe3xxUvhERPnweEoM+cWbVXU2+VgEh0=";
    } ];
    privateKeyFile = "/private/wg/privatekey";
    allowedIPsAsRoutes = false;
  };
}
