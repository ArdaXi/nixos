{ config, lib, pkgs, ... }:

let
  pymfy = ps: ps.buildPythonPackage rec {
    pname = "pymfy";
    version = "0.9.0";
    src = ps.fetchPypi {
      inherit pname version;
      sha256 = "sha256-6KB/YAckwRERj7jHrNT3qtoy6JABxMNek5sZhkSBWiM=";
    };
    propagatedBuildInputs = [ ps.requests_oauthlib ];
  };
in
{
  config = lib.mkMerge [
  {
    services.home-assistant = {
      enable = true;
      package = pkgs.home-assistant.override {
        extraPackages = ps: [
          (pymfy ps)
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
        extraConfig = ''
          proxy_ssl_verify off;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forward-For $proxy_add_x_forwarded_for;
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";
        '';
      };
    };
  }
  ];
}
