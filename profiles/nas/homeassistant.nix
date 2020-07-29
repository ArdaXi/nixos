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
          "somfy"
          "brother"
          "ipp"
        ];
      };
    };
  }
  {
    services.nginx.virtualHosts."home.street.ardaxi.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.home-assistant.port}/";
      };
    };
  }
  ];
}
