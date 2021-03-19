{ ... }:

{
  services.ipfs = {
    enable = true;
    gatewayAddress = "/ip4/127.0.0.1/tcp/8181";
  };

  networking.firewall.allowedTCPPorts = [ 4001 ];
}
