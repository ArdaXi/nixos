{ config, ... }:

{
  services.bind = {
    enable = true;
    cacheNetworks = [ "192.168.178.0/24" "127.0.0.0/24" "fe80::/64" "::1/128" ];
    forwarders = config.networking.nameservers;
    zones = [{
      name = "local.ardaxi.com";
      master = true;
      file = builtins.toFile "local.ardaxi.com" ''
        $ORIGIN local.ardaxi.com.
        $TTL 1h
        @ IN SOA @ root (1 1h 1h 4w 1h)
        @ IN NS  ns
        @ IN A   192.168.178.2
        * IN A   192.168.178.2
      '';
    }];
  };
}
