{ config, pkgs, lib, ... }:

with lib;

let
  hostName = "grocy.street.ardaxi.com";
in
{
  services.grocy = {
    inherit hostName;

    enable = true;

    settings = {
      currency = "EUR";
    };

    nginx.enableSSL = false;
  };

  services.nginx.virtualHosts.${hostName} = {
    forceSSL = true;
    enableACME = true;

    locations."~ \\.php$".extraConfig = ''
      allow 192.168.178.0/24;
      allow 192.168.179.0/24;
      allow 82.94.130.160/29;
      allow 2001:984:3f27::/48;
      deny all;
    '';
  };

}
