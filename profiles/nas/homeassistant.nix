{ config, lib, pkgs, ... }:

{
  config = lib.mkMerge [
  {
    services.home-assistant = {
      enable = true;
      package = pkgs.home-assistant.override {
        extraPackages = ps: [
          ps.pytado
        ];
        extraComponents = [
          "met"
          "updater"
          "zeroconf"
          "ssdp"
          "mqtt"
          "mobile_app"
          "tado"
          "tahoma"
        ];
      };
    };
  }
  {
    services.nginx.virtualHosts."local.street.ardaxi.com".locations."/home/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.home-assistant.port}/";
      extraConfig = ''
        allow 192.168.178.0/24;
        allow 82.94.130.160/29;
        allow 2001:984:3f27::/48;
        deny all;
      '';
    };
  }
  ];
}
