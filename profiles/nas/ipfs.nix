{ ... }:

{
  services.ipfs = {
    enable = true;
    gatewayAddress = "/ip4/0.0.0.0/tcp/8181";
    apiAddress = "/ip4/0.0.0.0/tcp/5001";
  };

  networking.firewall.allowedTCPPorts = [ 4001 ];
}
