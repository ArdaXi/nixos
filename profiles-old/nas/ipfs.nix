{ config, pkgs, lib, ... }:

{
  services.ipfs = {
    enable = true;
    autoMount = true;
  };

  networking.firewall.allowedTCPPorts = [ 4001 ];
}
