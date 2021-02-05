{ config, lib, ... }:

{
  services.nginx = {
    enable = true;
    statusPage = true;
    virtualHosts = let
      proxyConfig = ''
        proxy_ssl_verify   off;
        proxy_set_header   Host          $host;
        proxy_set_header   X-Real-IP     $remote_addr;
        proxy_set_header   X-Forward-For $proxy_add_x_forwarded_for;
        proxy_set_header   Upgrade       $http_upgrade;
        proxy_set_header   Connection    "upgrade";
        proxy_http_version 1.1;
      '';
      allow = ''
        allow 192.168.178.0/24;
        allow 82.94.130.160/29;
        allow 2001:984:3f27::/48;
        deny  all;
      '';
    in {
      "anki.street.ardaxi.com" = lib.mkIf config.services.ankisyncd.enable {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.ankisyncd.port}/";
          extraConfig = proxyConfig;
        };
      };
      "home.street.ardaxi.com" = lib.mkIf config.services.home-assistant.enable {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.home-assistant.port}/";
          extraConfig = proxyConfig;
        };
      };
      "hydra.street.ardaxi.com" = lib.mkIf config.services.hydra.enable {
        enableACME = true;
        addSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.hydra.port}";
          extraConfig = proxyConfig;
        };
      };
      "matrix.ardaxi.com" = lib.mkIf config.services.matrix-synapse.enable {
        enableACME = true;
        forceSSL = true;
        locations."/_matrix" = {
          proxyPass = "http://127.0.0.1:8008";
          extraConfig = "proxy_set_header X-Forwarded-For $remote_addr;";
        };
      };
      "nix-cache.street.ardaxi.com" = lib.mkIf config.services.nix-serve.enable {
        enableACME = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.nix-serve.port}";
        };
      };
      "unifi.street.ardaxi.com" = lib.mkIf config.services.unifi.enable {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "https://127.0.0.1:8443"; # seems hardcoded
          extraConfig = proxyConfig;
        };
      };
      "grafana.street.ardaxi.com" = lib.mkIf config.services.grafana.enable {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.grafana.port}";
        };
      };
      "street.ardaxi.com" = {
        enableACME = true;
        forceSSL = true;
      };
      "local.street.ardaxi.com" = {
        enableACME = true;
        addSSL = true;
        locations = {
          "/" = {
            alias = "/var/lib/nginx/index/";
            index = "index.html";
            extraConfig = allow;
          };
          "/espfw/" = {
            alias = "/var/lib/espfw/";
            extraConfig = ''
              autoindex on;
              allow 192.168.179.0/24;
            '' + allow;
          };
          "/hydra/" = lib.mkIf config.services.hydra.enable {
            proxyPass = "http://127.0.0.1:${toString config.services.hydra.port}/";
            extraConfig = allow;
          };
          "/media/" = {
            alias = "/media/";
            extraConfig = "autoindex on;" + allow;
          };
          "/sabnzbd/" = lib.mkIf config.services.sabnzbd.enable {
            proxyPass = "http://127.0.0.1:8081/"; # not declarative yet
            extraConfig = allow;
          };
          "/sickrage/" = lib.mkIf config.services.sickrage.enable {
            proxyPass = "http://127.0.0.1:8082";
            extraConfig = allow;
          };
          "/transmission/" = lib.mkIf config.services.transmission.enable {
            proxyPass = "http://127.0.0.1:${toString config.services.transmission.port}";
            extraConfig = allow;
          };
          "/nzbget/" = lib.mkIf config.services.nzbget.enable {
            proxyPass = "http://127.0.0.1:8083";
            extraConfig = allow;
          };
        };
      };
    };
  };
}
